# تشغيل VPN مؤقت عبر Tailscale من GitHub Actions

هذا إعداد **تجريبي** لتشغيل Runner مؤقت من GitHub كـ Tailscale Exit Node، ثم الاتصال به من تطبيق Tailscale على iPhone. لا يحتاج لابتوب أو Azure VM، لكنه ليس مضموناً؛ يجب أن يسمح Runner بواجهة TUN وتمرير الحزم.

## 1) جهّز Tailscale مرة واحدة

1. أنشئ حساباً في Tailscale وسجّل الدخول إلى لوحة الإدارة.
2. افتح **Access controls** وأنشئ Tag باسم `tag:github-exit`، واجعل حسابك/المسؤول مخوّلاً بإنشائه (TagOwners).
3. افتح **Settings → Keys → Generate auth key**.
4. أنشئ مفتاحاً بهذه الإعدادات:
   - Reusable: مفعّل.
   - Ephemeral: مفعّل.
   - Pre-approved: مفعّل إذا كان خيار موافقة الأجهزة مستخدماً.
   - Tag: اختر `tag:github-exit`.
5. انسخ المفتاح. لا ترسله في المحادثة ولا تضعه في ملفات المستودع.

## 2) أضف المفتاح إلى GitHub Secrets

1. افتح مستودع AZURE-VPN-TUNNEL-PRO.
2. Settings → Secrets and variables → Actions.
3. اضغط New repository secret.
4. الاسم بالضبط: `TAILSCALE_AUTHKEY`
5. الصق المفتاح كقيمة واحفظه.

## 3) شغّل الاتصال

1. افتح تبويب Actions.
2. اختر **Temporary Tailscale Exit Node (Experimental)**.
3. اضغط Run workflow.
4. اختر المدة من 30 إلى 300 دقيقة، ثم شغّل Workflow.
5. انتظر حتى تظهر خطوة **Advertise this runner as an exit node** وتطبع عنوان Tailscale IPv4.
6. افتح لوحة Tailscale الإدارية → Machines، وابحث عن الجهاز المؤقت ووافق على استخدامه كـ Exit Node إذا طلبت اللوحة ذلك.
7. على iPhone ثبّت تطبيق Tailscale وسجّل الدخول بنفس حساب Tailscale. افتح قائمة Exit Node واختر جهاز GitHub المؤقت.
8. عند الانتهاء، أوقف الاتصال من تطبيق Tailscale أو ألغِ تشغيل Workflow من GitHub. عند انتهاء المدة ينتهي الاتصال تلقائياً.

## حدود مهمة

- هذا ليس WireGuard server تقليدياً ولا ينتج ملف `.conf` للاستيراد في تطبيق WireGuard؛ الاتصال يتم عبر تطبيق Tailscale.
- الجهاز مؤقت، والاتصال يعمل فقط أثناء بقاء Workflow قيد التشغيل.
- قد يفشل الاختبار إذا لم يوفّر Runner واجهة `/dev/net/tun` أو لم يسمح بتمرير الحزم. في هذه الحالة يتوقف Workflow برسالة واضحة ولا يكون هناك VPN.
- قد يلزم اعتماد Exit Node يدوياً من لوحة Tailscale.
- لا تستخدم هذا لتجاوز قيود الشبكات أو سياسات GitHub/Tailscale. لا تشارك مفتاح المصادقة أو سجلات التشغيل التي قد تحتوي معلومات حساسة.
- يظل هذا اختباراً تجريبياً؛ نجاح خطوات Tailscale لا يضمن أن كل حركة إنترنت الهاتف ستعمل عبر Runner.

## الأمان

لا تضع مفتاح Tailscale في README أو ملفات YAML أو المحادثات. خزّنه فقط في GitHub Actions Secrets. إذا انكشف المفتاح، ألغِه فوراً من لوحة Tailscale وأنشئ واحداً جديداً.
