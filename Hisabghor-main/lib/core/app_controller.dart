import 'package:flutter/material.dart';

import '../data/business_repository.dart';
import 'app_constants.dart';

class AppController extends ChangeNotifier {
  AppController(this._repository);

  final BusinessRepository _repository;

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('bn');
  String _shopName = AppConstants.defaultShopName;
  bool _ready = false;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  String get shopName => _shopName.trim().isEmpty ? AppConstants.defaultShopName : _shopName.trim();
  bool get isReady => _ready;
  bool get isBangla => _locale.languageCode == 'bn';

  Future<void> load() async {
    final settings = await _repository.settings();
    _shopName = settings['shop_name']?.trim().isNotEmpty == true
        ? settings['shop_name']!.trim()
        : AppConstants.defaultShopName;
    final themeValue = settings['theme_mode'] ?? 'system';
    _themeMode = switch (themeValue) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final languageCode = settings['app_language'] ?? 'bn';
    _locale = Locale(languageCode == 'en' ? 'en' : 'bn');
    _ready = true;
    notifyListeners();
  }

  Future<void> setShopName(String value) async {
    final normalized = value.trim().isEmpty ? AppConstants.defaultShopName : value.trim();
    _shopName = normalized;
    await _repository.saveSetting('shop_name', normalized);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    final normalized = code == 'en' ? 'en' : 'bn';
    _locale = Locale(normalized);
    await _repository.saveSetting('app_language', normalized);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final stored = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _repository.saveSetting('theme_mode', stored);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final next = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }
}
