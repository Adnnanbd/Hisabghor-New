# হিসাবঘর Setup

`হিসাবঘর` is a Bangla/English Flutter business management app for sales, dues, stock, purchase, profit, reports, SMS reminders, Google Sheets backup, and Firebase Realtime Database sync.

## Build Requirements

1. Install Flutter SDK and Android Studio.
2. Run:

```powershell
flutter pub get
flutter analyze --no-fatal-infos
flutter build apk --debug
```

The generated debug APK will be under `build/app/outputs/flutter-apk/`.

## Firebase Setup

1. Copy `google-services.json` into `android/app/`.
2. This project is configured for Android package:

```text
com.hisabghor_busines.myapp
```

3. Open Firebase Console for project `hisabghor-business-73848`.
4. Enable **Realtime Database**.
5. Download a refreshed `google-services.json` after adding the final Android SHA-1 / SHA-256 if you want Google account sign-in to work reliably.

## Google Sheets Sync Setup

1. Open Google Cloud Console.
2. Use the same Firebase / Google project or a connected Google Cloud project.
3. Enable **Google Sheets API** and **Google Drive API**.
4. Configure OAuth consent screen.
5. Add Android OAuth client using package name:

```text
com.hisabghor_busines.myapp
```

6. Add the app signing SHA-1 and SHA-256 for the APK / Play signing key.
7. Download the refreshed Firebase/Google config and replace `android/app/google-services.json`.

Important: the provided `google-services.json` currently has no Android OAuth clients, so Google account login may stay blocked until the OAuth client + SHA values are added and the file is regenerated.

When a user signs in, the app creates or reuses a Google Sheet named `HISABGHOR_BACKUP` in that user account. The app syncs products, customers, sales, purchases, due payments, expenses, stock transactions, invoices, users, and settings.

## Firebase + Google Sheets Dual Sync

- SQLite remains the local-first database.
- Google Sheets stores tabular backup/export data.
- Firebase Realtime Database stores structured cloud backup and onboarding events.
- One sync target can fail without blocking the other.

## SMS Permission Note

The app supports four SMS modes from Settings:

- Manual copy: copies the Bangla due SMS so the user can paste it into any messaging app.
- Mobile SIM SMS: sends through the phone SIM and requires Android `SEND_SMS` permission.
- SSL Wireless API: enter endpoint, API token, and SID in Settings.
- BulkSMSBD API: enter endpoint, API key, and sender ID in Settings.

Direct SIM SMS may require special permission justification if publishing to Google Play.

## Contacts

The app reads phone contacts to import customer names/numbers. Android permissions added:

- `READ_CONTACTS`
- `WRITE_CONTACTS`

## Shop Name and Language

- Users can change the store/shop/business name from Settings.
- Bangla and English names are both supported.
- The top app bar uses the saved shop/business name.
- App UI can switch between Bangla and English.

## Import / Export

- Reports can be exported as `.xlsx` and `.csv`.
- Stock can be imported from `.csv` or `.xlsx`.
- Stock template export is included.
- Stock import columns:
  `barcode`, `name`, `purchase_price`, `sale_price`, `stock`, `low_stock_alert`

## Developer Details

Developer details are hard-coded in app constants and shown in About/settings/footer:

`Developer: Adnnan | WhatsApp: +8801911109390`

No setting is provided to remove this information.
