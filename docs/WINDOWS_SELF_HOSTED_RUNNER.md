# تشغيل GitHub Actions على لابتوب Windows 11 مع WireGuard

## الفكرة

يعمل هذا الـWorkflow على لابتوبك نفسه بعد تسجيله كـ self-hosted runner. GitHub يرسل مهمة يدوية، واللابتوب ينفذها طالما أنه يعمل ومتصل بالإنترنت.

هذا لا يجعل GitHub خادم VPN. الملف الحالي يفحص وجود WireGuard على اللابتوب فقط. إنشاء VPN فعلي يحتاج إعداد خادم WireGuard وجدار حماية Windows وإمكانية وصول الهاتف إلى اللابتوب من الإنترنت. قد يمنع CGNAT استقبال الاتصالات الواردة.

## المتطلبات

- لابتوب Windows 11 يبقى مشغلاً ومتصلًا بالإنترنت.
- صلاحية Administrator على اللابتوب.
- تثبيت تطبيق WireGuard الرسمي لنظام Windows من: https://www.wireguard.com/install/
- حساب GitHub مع صلاحية إدارة المستودع.

لا تضع مفاتيح WireGuard الخاصة أو كلمات المرور داخل المستودع أو ملفات Workflow.

## تسجيل اللابتوب كـ self-hosted runner

1. افتح المستودع في GitHub.
2. افتح Settings ثم Actions ثم Runners.
3. اضغط New self-hosted runner.
4. اختر Windows ثم x64.
5. اتبع أوامر GitHub الظاهرة لتنزيل Runner وفك ضغطه وتكوينه. لا تنشر رمز التسجيل أو ترسله لأحد.
6. شغّل run.cmd واترك نافذة التشغيل مفتوحة. انتظر ظهور Runner بحالة Idle/Online في GitHub.
7. لا تشغّل Runner على جهاز مشترك أو جهاز غير موثوق. لا تسمح بتشغيل Workflows من Pull Requests أو فروع أشخاص غير موثوقين على هذا الجهاز، لأن Runner ينفذ أوامر على Windows.

## تشغيل الفحص

1. افتح تبويب Actions.
2. اختر Check WireGuard on my Windows laptop.
3. اضغط Run workflow.
4. افتح نتيجة التشغيل.

رسالة النجاح المتوقعة:
PASS: GitHub self-hosted runner reached this Windows laptop and WireGuard tools were detected.

إذا ظهر أن WireGuard غير موجود، ثبّت التطبيق الرسمي ثم أعد الفحص.

## حدود هذا الملف

- لا ينشئ إعداد iPhone.
- لا يفتح منافذ الراوتر أو Windows Firewall.
- لا يفعّل IP forwarding أو NAT.
- لا يتجاوز CGNAT ولا يوفر عنواناً عاماً.
- لا يشغّل VPN تلقائياً؛ هو فحص تشخيصي فقط.

بعد نجاح الفحص، نحدد طريقة وصول الهاتف إلى اللابتوب قبل إعداد الخادم والعميل. لا تشارك أي PrivateKey أو QR يحتوي مفتاحاً خاصاً.
