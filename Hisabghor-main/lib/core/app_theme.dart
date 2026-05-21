import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFF0C7C59);

  static ThemeData light() {
    return _theme(Brightness.light);
  }

  static ThemeData dark() {
    return _theme(Brightness.dark);
  }

  static ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamilyFallback: const ['Noto Sans Bengali', 'Noto Sans', 'Roboto'],
      scaffoldBackgroundColor:
          brightness == Brightness.dark ? const Color(0xFF111315) : const Color(0xFFF4F1EA),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: brightness == Brightness.dark ? const Color(0xFF172026) : const Color(0xFF12343B),
        foregroundColor: scheme.onPrimary,
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: brightness == Brightness.dark ? const Color(0xFF1A1F23) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: brightness == Brightness.dark ? const Color(0xFF1A2127) : Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
