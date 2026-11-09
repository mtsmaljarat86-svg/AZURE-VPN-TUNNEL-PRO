# AZURE VPN TUNNEL PRO

إعداد خادم WireGuard VPN على Ubuntu داخل Microsoft Azure، ثم تجهيز ملف عميل لاستيراده على iPhone.

## كيف يعمل؟
iPhone (تطبيق WireGuard) → نفق VPN مشفّر → Azure Ubuntu VM → الإنترنت.

## 1. جهّز خادم Azure
أنشئ Virtual Machine بنظام Ubuntu 22.04 أو 24.04، مع Public IPv4. في Network Security Group أضف قاعدة واردة:
- Protocol: UDP
- Destination port: 51820
- Source: Any (أو نطاق موثوق مناسب)
- Action: Allow

اترك SSH على TCP 22 مقيداً بعنوان IP موثوق، ولا تفتح منافذ غير مطلوبة. تأكد أن حساب SSH يستطيع تنفيذ sudo.

## 2. أضف GitHub Actions Secrets
في المستودع افتح Settings → Secrets and variables → Actions → New repository secret، وأضف القيم التالية:

| Secret name | القيمة |
|---|---|
| AZURE_HOST | عنوان IPv4 العام لخادم Azure |
| AZURE_PUBLIC_IP | عنوان IPv4 العام نفسه |
| AZURE_USER | اسم مستخدم SSH على Ubuntu |
| AZURE_SSH_PRIVATE_KEY | المفتاح الخاص SSH الذي يسمح بالدخول إلى الخادم |
| AZURE_SSH_KNOWN_HOSTS | مفتاح المضيف الموثوق للخادم (known_hosts) |

لإنشاء سطر known_hosts يمكنك تشغيل:
```bash
ssh-keyscan -H YOUR_AZURE_PUBLIC_IP
```
تحقق من بصمة المضيف عبر مصدر موثوق قبل حفظها. لا تعطل فحص هوية المضيف ولا تستخدم `StrictHostKeyChecking=no`.

**لا تضع المفاتيح الخاصة أو كلمات المرور في ملفات المستودع أو المحادثات.** خزّنها في Secrets فقط.

## 3. شغّل Workflow
1. افتح تبويب Actions.
2. اختر Install WireGuard on Azure.
3. اضغط Run workflow.
4. انتظر انتهاء التشغيل بنجاح.

سيُنشأ Artifact باسم `wireguard-client-config` يحتوي:
- `iphone.conf`
- `iphone-qr.png`

نزّل الـ Artifact من صفحة تشغيل Workflow. مدة الاحتفاظ به يوم واحد لأنه يحتوي مفتاحاً خاصاً.

## 4. استيراد الإعداد على iPhone
1. ثبّت تطبيق WireGuard الرسمي.
2. انقل `iphone.conf` إلى iPhone وافتحه باستخدام WireGuard، أو امسح QR من جهاز آخر.
3. فعّل النفق.
4. افحص عنوان IP من متصفحك للتأكد من أن الاتصال يخرج عبر خادم Azure.

## ملاحظات مهمة
- هذا المشروع لا ينشئ Azure VM ولا يدفع تكلفتها. قد تُحتسب رسوم على VM وعنوان IP ونقل البيانات الصادرة.
- السكربت ينشئ إعداد خادم جديداً ويرفض استبدال `/etc/wireguard/wg0.conf` إذا كان موجوداً.
- إعداد العميل الحالي يوجّه IPv4 فقط (`0.0.0.0/0`). لا تعتبره حماية من تسرب IPv6؛ يلزم إعداد IPv6 منفصل أو تعطيله على العميل.
- يجب أن تسمح قواعد Azure NSG وجدار الحماية داخل Ubuntu بحركة UDP على المنفذ 51820.
- أوقف الـ VM عندما لا تحتاجها لتقليل التكلفة، مع الانتباه إلى أن بعض الموارد قد تبقى عليها رسوم.
- ملف `iphone.conf` سرّي: من يحصل عليه يستطيع استخدام النفق. احذف الـ Artifact بعد تنزيله إذا لم تعد تحتاجه.
