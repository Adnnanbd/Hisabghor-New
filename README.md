# হিসাবঘর Pro 🏪

**বাংলা স্টোর ম্যানেজমেন্ট অ্যাপ** | Smart Store Management App

---

## ✅ Features

| Feature | Status |
|---|---|
| Dashboard (আজকের বিক্রয়, বাকি, লাভ, সর্বোচ্চ বাকি গ্রাহক) | ✅ |
| নতুন বিক্রয় (একাধিক পণ্য, ছাড়, লাভ স্বয়ংক্রিয় হিসাব) | ✅ |
| গ্রাহক ব্যবস্থাপনা (যোগ, সম্পাদনা, মুছুন, পেমেন্ট সংগ্রহ) | ✅ |
| বাকি হিসাব ও পেমেন্ট গ্রহণ | ✅ |
| SMS পাঠানো (SSL Wireless, BulkSMSBD, Manual) | ✅ |
| পণ্য ও স্টক ব্যবস্থাপনা | ✅ |
| মাসিক রিপোর্ট (তারিখ ফিল্টার সহ) | ✅ |
| Excel রিপোর্ট ডাউনলোড | ✅ |
| ডার্ক/লাইট থিম | ✅ |
| বাংলা / English ভাষা | ✅ |
| অফলাইন — ইন্টারনেট ছাড়া কাজ করে | ✅ |

---

## 🚀 APK Build via GitHub Actions

### Step 1 — Push to GitHub
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/hisabghor.git
git push -u origin main
```

### Step 2 — GitHub will auto-build
Go to your repo → **Actions** tab → **Build & Release APK** → Wait ~5 min

### Step 3 — Download APK
Actions → Click the latest run → **Artifacts** → Download `hisabghor-release-apk`

---

## 📱 SMS Setup

### SSL Wireless (Bangladesh)
1. Sign up at https://sslwireless.com
2. Get your **API Token** and **Sender ID**
3. In app → Settings → SMS Provider → SSL Wireless → Enter credentials

### BulkSMSBD
1. Sign up at https://bulksmsbd.net
2. Get your **API Key** and **Sender ID**
3. In app → Settings → SMS Provider → BulkSMSBD → Enter credentials

### Manual (No API needed)
- SMS text is automatically copied to clipboard
- Open your phone's messaging app and paste

---

## 🔧 Local Development

```bash
flutter pub get
flutter run
```

**Requirements:** Flutter 3.24+, Dart 3.4+, Android SDK 23+

---

## 👨‍💻 Developer

- **Name:** Adnnan  
- **WhatsApp:** +8801911109390  
- **Email:** adnnanrahman@gmail.com
