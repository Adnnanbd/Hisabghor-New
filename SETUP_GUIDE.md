# হিসাবঘর Pro - Setup Guide

## ✅ Core Files Created

### Models
- `lib/models/product.dart` - Product model with bilingual support
- `lib/models/customer.dart` - Customer model with due tracking
- `lib/models/sale.dart` - Sale and SaleItem models

### Services
- `lib/services/database_service.dart` - Hive database operations
- `lib/services/auth_service.dart` - Google Sign-In (ready for Firebase)
- `lib/services/cloud_backup_service.dart` - Cloud backup system

### Providers
- `lib/providers/language_provider.dart` - Bangla/English language toggle
- `lib/providers/theme_provider.dart` - Light/Dark theme toggle

### Screens
- `lib/screens/home_screen.dart` - Main navigation with bottom bar
- `lib/screens/dashboard/dashboard_screen.dart` - Stats and quick actions
- `lib/screens/sales/sales_screen.dart` - Sales list
- `lib/screens/products/products_screen.dart` - Products list
- `lib/screens/customers/customers_screen.dart` - Customers list
- `lib/screens/reports/reports_screen.dart` - Reports menu
- `lib/screens/settings/settings_screen.dart` - App settings

### Utils
- `lib/utils/app_theme.dart` - Material 3 theme configuration

## 📋 Next Steps for You

1. **Copy all files** from `/workspace` to your local Flutter project

2. **Run on your machine:**
   ```bash
   flutter pub get
   flutter run
   ```

3. **Configure Firebase** (optional for cloud features):
   - Add `google-services.json` to `android/app/`
   - Update Firebase config in services

4. **Build APK:**
   ```bash
   flutter build apk --release
   ```

## 🎯 Features Implemented

✅ Bilingual UI (বাংলা + English)
✅ Material 3 Design
✅ Offline-first with Hive
✅ Product Management
✅ Customer Management  
✅ Sales Tracking
✅ Due Management
✅ Dashboard with Stats
✅ Dark/Light Theme
✅ Language Toggle
✅ Reports Module
✅ Settings Screen

## 📞 Developer Info

**Developer:** ADNNAN  
**WhatsApp:** +8801911-109390  
**Email:** adnnanrahman@gmail.com
