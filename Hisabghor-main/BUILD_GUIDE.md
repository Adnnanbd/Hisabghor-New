# হিসাবঘর Pro - Build Guide

## Project Structure Created ✅

The following core structure has been created for your advanced bilingual store management app:

### Core Files Created:
1. **Models** (`lib/models/`):
   - `product.dart` - Product model with Hive annotations
   - `customer.dart` - Customer model with Hive annotations
   - `sale.dart` - Sale and SaleItem models with Hive annotations

2. **Providers** (`lib/providers/`):
   - `language_provider.dart` - Manages Bangla/English language switching

3. **Services** (`lib/services/`):
   - `database_service.dart` - Hive database operations for products, customers, sales

4. **Utils** (`lib/utils/`):
   - `app_strings.dart` - Complete bilingual translations (Bangla + English)
   - `app_theme.dart` - Material 3 theming with language support

5. **Screens** (`lib/screens/`):
   - `home_screen.dart` - Main navigation with bottom bar
   - `dashboard/dashboard_screen.dart` - Dashboard with stats and charts
   - `sales/sales_screen.dart` - Sales module (placeholder)
   - `products/products_screen.dart` - Products module (placeholder)
   - `customers/customers_screen.dart` - Customers module (placeholder)
   - `reports/reports_screen.dart` - Reports module (placeholder)
   - `settings/settings_screen.dart` - Settings with language switcher

6. **Main Entry**:
   - `main.dart` - App initialization with Hive and providers

## Next Steps to Complete the App

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Generate Hive Adapters
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate the `.g.dart` files for:
- `ProductAdapter`
- `CustomerAdapter`
- `SaleItemAdapter`
- `SaleAdapter`

### Step 3: Add Firebase Configuration

1. Create a Firebase project at https://console.firebase.google.com
2. Add an Android app with package name: `com.adnnan.apps.hisabghor_pro`
3. Download `google-services.json` and place it in `android/app/`
4. Enable these Firebase services:
   - Firebase Authentication (Google Sign-In)
   - Cloud Firestore
   - Firebase Storage

### Step 4: Configure Google Sheets API

1. Go to https://console.cloud.google.com
2. Enable Google Sheets API
3. Create OAuth 2.0 credentials
4. Add credentials to your app for cloud backup

### Step 5: Update Android Configuration

Edit `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        applicationId "com.adnnan.apps.hisabghor_pro"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    signingConfigs {
        release {
            // Add your keystore details here
        }
    }
}
```

### Step 6: Add Required Permissions

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.READ_CONTACTS"/>
<uses-permission android:name="android.permission.WRITE_CONTACTS"/>
<uses-permission android:name="android.permission.SEND_SMS"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### Step 7: Implement Remaining Features

#### A. Smart Product Search (Priority Feature)
Create `lib/widgets/product_search_field.dart`:
- Autocomplete dropdown
- Bangla + English search support
- Auto-fill buy price, sell price, stock quantity

#### B. Sales Module
Create complete sales screen with:
- Multi-product cart
- Customer selection
- Discount/VAT calculation
- Due management
- Invoice generation (PDF)
- WhatsApp sharing

#### C. Product Management
Create full CRUD operations:
- Add/Edit/Delete products
- Barcode scanner integration
- Image upload
- Stock alerts

#### D. Customer Management
Implement:
- Customer CRUD
- Due tracking
- Payment history
- SMS/WhatsApp integration

#### E. Reports Module
Generate:
- Daily/Monthly reports
- Due reports
- Profit/Loss analysis
- Export to PDF/Excel

#### F. Cloud Backup
Implement:
- Google Sheets sync
- Firebase backup
- Restore functionality

### Step 8: Testing

Test these critical features:
1. ✅ Language switching (Bangla ↔ English)
2. ✅ Dashboard stats display
3. ⏳ Product search in Bangla/English
4. ⏳ Sale with auto-price fill
5. ⏳ Due management
6. ⏳ SMS integration (SSL Wireless/BulkSMSBD)
7. ⏳ Google Sign-In
8. ⏳ Cloud backup/restore

### Step 9: Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

### Step 10: Play Store Setup

1. Create developer account at https://play.google.com/console
2. Prepare store listing:
   - App name: হিসাবঘর Pro | Hisabghor Pro
   - Short description: বাংলা + ইংরেজি স্টোর ম্যানেজমেন্ট অ্যাপ
   - Screenshots (Bangla + English)
   - Feature graphic
   - Privacy policy

## Key Features Implemented So Far

✅ **Bilingual Support** (Bangla + English)
- Dynamic language switching
- Complete translation system
- Bangla font support (Hind Siliguri)

✅ **Modern UI/UX**
- Material 3 design
- Bottom navigation
- Responsive layouts
- Dark/Light theme ready

✅ **Database Layer**
- Hive local storage
- Product, Customer, Sale models
- Offline-first architecture

✅ **Dashboard**
- Today sales统计
- Total due calculation
- Monthly profit
- Stock value
- Low stock alerts
- Sales chart (fl_chart)

✅ **Settings**
- Language switcher
- About dialog with developer info
- Business info section (ready for implementation)

## Developer Information

**Developer:** ADNNAN  
**WhatsApp:** +8801911-109390  
**Email:** adnnanrahman@gmail.com  

## Recommended Priority Order

1. **HIGH PRIORITY** - Core Functionality:
   - Product search with Bangla/English autocomplete
   - Sales system with auto-price fill
   - Due management

2. **MEDIUM PRIORITY** - Business Features:
   - Customer management
   - Reports generation
   - PDF invoice

3. **LOW PRIORITY** - Advanced Features:
   - Google Sign-In
   - Cloud backup
   - SMS integration
   - Barcode scanner

## File Structure Summary

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── product.dart            # Product model
│   ├── customer.dart           # Customer model
│   └── sale.dart               # Sale & SaleItem models
├── providers/
│   └── language_provider.dart  # Language state management
├── screens/
│   ├── home_screen.dart        # Main navigation
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── sales/
│   ├── products/
│   ├── customers/
│   ├── reports/
│   └── settings/
│       └── settings_screen.dart
├── services/
│   └── database_service.dart   # Hive operations
├── utils/
│   ├── app_strings.dart        # Translations
│   └── app_theme.dart          # Theming
└── widgets/                    # (To be created)
```

## Support

For questions or issues:
- WhatsApp: +8801911-109390
- Email: adnnanrahman@gmail.com

---

**হিসাবঘর Pro** - আপনার ব্যবসার জন্য সবচেয়ে উন্নত স্টোর ম্যানেজমেন্ট সলিউশন!

*Developed by ADNNAN*
