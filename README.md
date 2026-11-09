# AZURE VPN TUNNEL PRO

مشروع لتجهيز خادم Ubuntu على Microsoft Azure ليعمل كخادم WireGuard VPN، ثم تنزيل إعداد عميل لاستيراده في تطبيق WireGuard على iPhone.

## البنية
iPhone (WireGuard) → نفق مشفّر → Azure Ubuntu VM → الإنترنت.

## المتطلبات
- Azure Ubuntu VM مع Public IPv4.
- السماح بمنفذ UDP 51820 في Azure Network Security Group.
- SSH مقيد بعنوان IP موثوق.
- GitHub Actions Secrets لإعداد الاتصال الآمن بالخادم.

## تنبيه
هذا المستودع لا ينشئ Azure VM ولا يغطي تكلفتها. قد تُحتسب رسوم على الآلة الافتراضية وعنوان IP ونقل البيانات. لا تضع مفاتيح خاصة أو كلمات مرور داخل ملفات المستودع. ملف إعداد WireGuard للعميل يحتوي مفتاحاً خاصاً ويجب حفظه بسرية.

سيتم إضافة ملفات التثبيت وWorkflow بعد ضبط صلاحيات الكتابة المطلوبة لتكامل GitHub.
