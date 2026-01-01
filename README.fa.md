# MtxDeploy

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)  
پروژه‌ای برای راه‌اندازی سرور Matrix با استفاده از داکر، Traefik و Synapse با قابلیت Delegation کامل و احراز هویت MAS.

---

### مرور کلی
این پروژه یک ستاپ کامل سرور ماتریکس را ارائه می‌دهد که شامل موارد زیر است:
*   **Synapse**: پیاده‌سازی مرجع سرور ماتریکس.
*   **MAS**: سیستم احراز هویت مدرن مبتنی بر OIDC.
*   **Element Web**: کلاینت اصلی وب ماتریکس.
*   **Sliding Sync**: سینک پرسرعت برای کلاینت‌های نسل جدید.
*   **Traefik**: ریورس پروکسی با مدیریت خودکار SSL.
*   **Ntfy**: سیستم نوتیفیکیشن UnifiedPush.
*   **Synapse Admin**: پنل مدیریت گرافیکی سرور.

> [!NOTE]
> **بایپس وریفای ایمیل:**
> به دلیل محدودیت‌های اینترنتی در برخی کشورها (مانند ایران)، نسخه MAS استفاده شده در این پروژه پچ شده است تا وریفای ایمیل را دور بزند. کافیست هنگام درخواست کد، هر عددی (مثلاً `111111`) وارد کنید.
>
> **استفاده از نسخه رسمی:**
> اگر می‌خواهید از ایمیج رسمی استفاده کنید، فایل `configs/chat_server/docker-compose.yml` را ویرایش کرده و ایمیج MAS را به شکل زیر تغییر دهید:
> `image: "ghcr.io/matrix-org/matrix-authentication-service:${MAS_VERSION}"`

---

### معماری
این پروژه از **Matrix Delegation** استفاده می‌کند تا دامین هویت کاربر را از دامین سرویس جدا کند.

*   **دامین هویت کاربر:** `example.com` (مثال: `@user:example.com`)
*   **دامین سرویس:** `chat.example.com` (میزبانی Synapse, MAS, Element)

کلاینت‌ها با جستجوی `example.com` به صورت خودکار به `chat.example.com` هدایت می‌شوند.

---

### پیش‌نیازها
*   یک سرور لینوکس (پیشنهاد: Debian/Ubuntu)
*   داکر و داکر کامپوز
*   پایتون ۳ و `uv` (برای تولید کانفیگ)
*   یک دامین که به سرور اشاره کند

---

### نصب

#### ۱. پیکربندی محیط
فایل نمونه کانفیگ را کپی کرده و اطلاعات دامین و پسوردهای خود را وارد کنید.

```bash
cp env.example.yml env.yml
nano env.yml
```

#### ۲. اجرای اسکریپت نصب
اسکریپت `gen_config.sh` را اجرا کنید. این اسکریپت کارهای زیر را انجام می‌دهد:
*   تولید تمام فایل‌های کانفیگ مورد نیاز.
*   ایجاد شبکه داکر (`edge`).
*   دانلود نسخه مناسب Element Web.
*   تنظیم دسترسی‌های (Permissions) پوشه‌های دیتا.

```bash
bash gen_config.sh
```

#### ۳. شروع سرویس‌ها
به پوشه‌های کانفیگ بروید و کانتینرها را اجرا کنید.

```bash
# اجرای Traefik
cd configs/edge
docker compose up -d

# اجرای سرویس‌های ماتریکس
cd ../chat_server
docker compose up -d
```

---

### سرویس‌ها و آدرس‌ها
فرض کنیم دامین اصلی شما `example.com` است:

| سرویس | آدرس | توضیحات |
| :--- | :--- | :--- |
| **Element Web** | `https://chat.example.com` | کلاینت وب |
| **Synapse** | `https://chat.example.com` | API سرور اصلی |
| **Auth** | `https://auth.chat.example.com` | صفحه لاگین MAS |
| **Ntfy** | `https://ntfy.example.com` | نوتیفیکیشن |
| **Admin Panel** | `https://matrix-admin.example.com` | مدیریت سرور |
| **Traefik** | `https://to.chat.example.com` | داشبورد پروکسی |

---

### تشکر و قدردانی
با تشکر ویژه از [wiiz-ir](https://github.com/wiiz-ir/matrix-2-scripts) بابت اسکریپت‌های اولیه و الهام‌بخشی.

---

### مجوز
این پروژه تحت مجوز MIT منتشر شده است.
