import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('bn');

  Locale get locale => _locale;
  
  bool get isBangla => _locale.languageCode == 'bn';
  
  String get currentLanguage => isBangla ? 'বাংলা' : 'English';

  void setLanguage(String languageCode) {
    _locale = Locale(languageCode);
    notifyListeners();
  }

  void toggleLanguage() {
    _locale = isBangla ? const Locale('en') : const Locale('bn');
    notifyListeners();
  }

  String tr(String key, {Map<String, String>? bangla, Map<String, String>? english}) {
    final strings = isBangla 
        ? (bangla ?? _defaultBanglaStrings)
        : (english ?? _defaultEnglishStrings);
    return strings[key] ?? key;
  }

  static final Map<String, String> _defaultBanglaStrings = {
    'dashboard': 'ড্যাশবোর্ড',
    'products': 'পণ্য',
    'sales': 'বিক্রয়',
    'customers': 'গ্রাহক',
    'reports': 'রিপোর্ট',
    'settings': 'সেটিংস',
    'save': 'সংরক্ষণ',
    'cancel': 'বাতিল',
    'delete': 'মুছুন',
    'edit': 'সম্পাদনা',
    'add': 'যোগ করুন',
    'search': 'অনুসন্ধান',
  };

  static final Map<String, String> _defaultEnglishStrings = {
    'dashboard': 'Dashboard',
    'products': 'Products',
    'sales': 'Sales',
    'customers': 'Customers',
    'reports': 'Reports',
    'settings': 'Settings',
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'edit': 'Edit',
    'add': 'Add',
    'search': 'Search',
  };
}
