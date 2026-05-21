import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('bn'),
    Locale('en'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final value = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(value != null, 'AppLocalizations পাওয়া যায়নি');
    return value!;
  }

  static const Map<String, Map<String, String>> _strings = {
    'bn': {
      'dashboard': 'ড্যাশবোর্ড',
      'purchase': 'ক্রয়',
      'sale': 'বিক্রয়',
      'customers_due': 'কাস্টমার ও বাকি',
      'book_list': 'বই তালিকা',
      'product_list': 'পণ্য তালিকা',
      'stock_book': 'স্টক বুক',
      'business_report': 'ব্যবসা রিপোর্ট',
      'contacts': 'কনট্যাক্টস',
      'settings': 'সেটিংস',
      'today_sale': 'আজকের বিক্রয়',
      'today_expense': 'আজকের খরচ',
      'today_balance': 'আজকের ব্যালেন্স',
      'monthly_balance': 'মাসিক ব্যালেন্স',
      'total_due': 'মোট বাকি',
      'stock_count': 'স্টক গণনা',
      'highest_due': 'সর্বোচ্চ বাকি',
      'main_menu': 'প্রধান মেনু',
      'quick_actions': 'দ্রুত কাজ',
      'cloud_sync': 'ক্লাউড সিঙ্ক',
      'books': 'বইসমূহ',
      'for_business': 'আপনার ব্যবসার জন্য',
      'language': 'ভাষা',
      'bangla': 'বাংলা',
      'english': 'English',
      'google_sheets_sync': 'গুগল শিটস সিঙ্ক',
      'firebase_sync': 'ফায়ারবেজ সিঙ্ক',
      'restore_google': 'গুগল শিটস থেকে রিস্টোর',
      'restore_firebase': 'ফায়ারবেজ থেকে রিস্টোর',
      'sync_status': 'সিঙ্ক অবস্থা',
      'manual_copy': 'ম্যানুয়াল কপি',
      'device_sms': 'মোবাইল SIM SMS',
      'developer': 'ডেভেলপার',
      'save': 'সংরক্ষণ করুন',
      'cancel': 'বাতিল',
      'add': 'যোগ করুন',
      'search': 'খুঁজুন',
      'purchase_book': 'ক্রয় বই',
      'sales_book': 'বিক্রয় বই',
      'due_book': 'বাকি বই',
      'expenses_book': 'খরচ বই',
      'contacts_import': 'ফোন কনট্যাক্ট আমদানি',
      'reports_export': 'CSV / XLSX এক্সপোর্ট',
      'sync_help': 'Google OAuth সঠিকভাবে সেটআপ না থাকলে Google account loading হতে পারে।',
      'configuration_needed': 'কনফিগারেশন প্রয়োজন',
      'shop_name': 'স্টোর / শপ / ব্যবসার নাম',
      'purchase_supplier': 'সরবরাহকারী / উৎস',
      'payment_collection': 'পেমেন্ট গ্রহণ',
      'send_due_sms': 'বাকি SMS পাঠান',
      'import_stock': 'স্টক ইমপোর্ট',
      'export_template': 'টেমপ্লেট এক্সপোর্ট',
      'low_stock': 'কম স্টক',
      'monthly_report': 'মাসিক রিপোর্ট',
      'theme': 'থিম',
      'dark_mode': 'ডার্ক মোড',
      'light_mode': 'লাইট মোড',
      'welcome': 'স্বাগতম',
      'shop_summary': 'দৈনিক ও মাসিক হিসাব এক নজরে',
      'purchase_vs_sale': 'ক্রয় বনাম বিক্রয়',
      'new_install_notice': 'নতুন সেটআপ ইভেন্ট ফায়ারবেজে পাঠানো হবে',
      'google_blocked': 'Google account sign-in এর জন্য Firebase / OAuth config refresh প্রয়োজন',
      'sync_now': 'এখনই সিঙ্ক করুন',
      'restore_now': 'এখনই রিস্টোর',
      'export_csv': 'CSV এক্সপোর্ট',
      'export_xlsx': 'XLSX এক্সপোর্ট',
      'sync_center': 'সিঙ্ক সেন্টার',
    },
    'en': {
      'dashboard': 'Dashboard',
      'purchase': 'Purchase',
      'sale': 'Sale',
      'customers_due': 'Customers & Due',
      'book_list': 'Book List',
      'product_list': 'Product List',
      'stock_book': 'Stock Book',
      'business_report': 'Business Report',
      'contacts': 'Contacts',
      'settings': 'Settings',
      'today_sale': "Today's Sale",
      'today_expense': "Today's Expense",
      'today_balance': "Today's Balance",
      'monthly_balance': 'Monthly Balance',
      'total_due': 'Total Due',
      'stock_count': 'Stock Count',
      'highest_due': 'Highest Due',
      'main_menu': 'Main Menu',
      'quick_actions': 'Quick Actions',
      'cloud_sync': 'Cloud Sync',
      'books': 'Books',
      'for_business': 'For Your Business',
      'language': 'Language',
      'bangla': 'Bangla',
      'english': 'English',
      'google_sheets_sync': 'Google Sheets Sync',
      'firebase_sync': 'Firebase Sync',
      'restore_google': 'Restore from Google Sheets',
      'restore_firebase': 'Restore from Firebase',
      'sync_status': 'Sync Status',
      'manual_copy': 'Manual Copy',
      'device_sms': 'Device SIM SMS',
      'developer': 'Developer',
      'save': 'Save',
      'cancel': 'Cancel',
      'add': 'Add',
      'search': 'Search',
      'purchase_book': 'Purchase Book',
      'sales_book': 'Sales Book',
      'due_book': 'Due Book',
      'expenses_book': 'Expenses Book',
      'contacts_import': 'Import Phone Contacts',
      'reports_export': 'Export CSV / XLSX',
      'sync_help': 'If Google OAuth is not configured correctly, Google account sign-in may keep loading.',
      'configuration_needed': 'Configuration Needed',
      'shop_name': 'Store / Shop / Business Name',
      'purchase_supplier': 'Supplier / Source',
      'payment_collection': 'Receive Payment',
      'send_due_sms': 'Send Due SMS',
      'import_stock': 'Import Stock',
      'export_template': 'Export Template',
      'low_stock': 'Low Stock',
      'monthly_report': 'Monthly Report',
      'theme': 'Theme',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'welcome': 'Welcome',
      'shop_summary': 'Daily and monthly business summary at a glance',
      'purchase_vs_sale': 'Purchase vs Sale',
      'new_install_notice': 'A new setup event will be sent to Firebase',
      'google_blocked': 'Google account sign-in still needs refreshed Firebase / OAuth config',
      'sync_now': 'Sync Now',
      'restore_now': 'Restore Now',
      'export_csv': 'Export CSV',
      'export_xlsx': 'Export XLSX',
      'sync_center': 'Sync Center',
    },
  };

  String text(String key) => _strings[locale.languageCode]?[key] ?? _strings['bn']![key] ?? key;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['bn', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
