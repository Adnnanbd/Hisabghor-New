import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('bn');

  Locale get locale => _locale;

  void loadSaved() {
    // Load saved locale from preferences (stub implementation)
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}
