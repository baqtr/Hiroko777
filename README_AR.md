# ملفات تعدين XMR على Heroku بتصريح مكتوب

استخدم هذه الملفات فقط إذا كان لديك موافقة مكتوبة وصريحة من Heroku/Salesforce لنفس التطبيق والحساب ونوع الـ dyno.

## أين أضع عنوان المحفظة؟

ضع عنوان محفظة Monero/XMR داخل ملف:

```bash
config.env
```

في هذا السطر:

```bash
XMR_WALLET="PUT_YOUR_XMR_RECEIVE_ADDRESS_HERE"
```

استبدله بعنوان الاستلام من محفظتك:

```bash
XMR_WALLET="عنوان_XMR_الخاص_بك"
```

لا تضع Seed Phrase أو Private Key أبدًا.

## التشغيل السريع

```bash
unzip heroku_xmr_authorized_v1.zip
cd heroku_xmr_authorized_v1
chmod +x *.sh
nano config.env
bash quick_start.sh
```

سيقوم السكربت بـ:

1. التحقق من Heroku CLI و Git.
2. إنشاء التطبيق إذا لم يكن موجودًا.
3. ضبط Stack على container.
4. ضبط Config Vars.
5. رفع الملفات عبر Git إلى Heroku.
6. تشغيل worker=1 وإيقاف web=0.
7. عرض logs.

## أوامر مفيدة

عرض السجل:

```bash
bash logs.sh
```

تغيير عدد العمال أو حجم dyno:

```bash
bash scale_worker.sh 1 standard-2x
```

إيقاف التعدين:

```bash
bash stop.sh
```

## ملاحظات مهمة

- أفضل تشغيل للتعدين على Heroku هو worker dyno، وليس web dyno.
- إذا لم يظهر worker، تأكد أن `heroku.yml` موجود في جذر المشروع وأن Stack هو container.
- إذا ظهر خطأ صلاحيات أو تعليق حساب، راجع موافقة Heroku المكتوبة وحدودها.
- كلمة `accepted` في السجل تعني أن الـ pool قبل المشاركات.
