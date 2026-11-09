# AZURE VPN TUNNEL PRO — GitHub Actions test mode

هذا الإصدار يعمل **بدون Azure وبدون خادم خارجي**. يستخدم جهاز GitHub Actions المؤقت لتثبيت أدوات WireGuard، وتوليد مفاتيح اختبار مؤقتة، وفحص صيغة ملف إعداد تجريبي.

## مهم: ما الذي يفعله وما الذي لا يفعله؟

- ✅ يختبر أن أدوات WireGuard تعمل على بيئة Ubuntu الخاصة بـ GitHub Actions.
- ✅ يولّد مفاتيح مؤقتة داخل مساحة التشغيل، ثم يفحص صيغة الإعداد باستخدام `wg-quick strip`.
- ✅ لا يحتاج Azure VM أو SSH أو GitHub Secrets.
- ❌ لا ينشئ خادماً عاماً يمكن للآيفون الاتصال به.
- ❌ لا ينشئ ملف `iphone.conf` صالحاً للاتصال بالإنترنت، ولا يرفع مفاتيح أو ملفات VPN كـArtifact.
- ❌ لا يحوّل GitHub Actions إلى VPN دائم أو نقطة خروج إنترنت للآيفون.

جهاز GitHub Actions مؤقت، ويُزال بعد انتهاء المهمة. الحد الأقصى المعتاد لوظائف GitHub-hosted runner هو 6 ساعات، لكن هذا الاختبار ينتهي خلال دقائق قليلة؛ لا توجد مدة VPN فعلية لأن النفق غير منشأ أصلاً.

## طريقة التشغيل

1. افتح تبويب **Actions** في المستودع.
2. اختر **Test WireGuard on GitHub Actions**.
3. اضغط **Run workflow** ثم **Run workflow** مرة ثانية للتأكيد.
4. افتح التشغيل وانتظر خطوة **Generate temporary test keys and validate config**.
5. ظهور الرسالة التالية يعني نجاح اختبار الصيغة فقط:

```
PASS: WireGuard tools installed; temporary keys generated; config parsed.
```

## هل أحتاج أسرار GitHub؟

لا. احذف أو اترك دون استخدام أي Secrets قديمة باسم `AZURE_HOST` أو `AZURE_USER` أو `AZURE_SSH_PRIVATE_KEY` أو غيرها؛ هذا الاختبار لا يقرأها ولا يحتاجها. لا تضع مفاتيح خاصة في المستودع.

## ملفات المشروع

- `.github/workflows/install-wireguard.yml`: أصبح اختباراً محلياً لأدوات وصيغة WireGuard داخل Runner.
- `scripts/install-wireguard.sh`: سكربت إعداد خادم Ubuntu قديم يتطلب root وخادماً تملكه؛ **لا يشغله Workflow الاختبار**. لا تشغّله على جهازك أو أي خادم دون فهم التغييرات التي يجريها.

## إذا كان هدفك VPN فعلياً على iPhone

تحتاج نقطة نهاية WireGuard يمكن الوصول إليها من الإنترنت وتظل متاحة أثناء اتصال الهاتف. GitHub Actions لا يوفر ذلك كخدمة VPN مستمرة. استخدم خادماً تملكه أو مزود VPN موثوقاً؛ يمكن إبقاء هذا الـWorkflow لفحص الإعدادات فقط.
