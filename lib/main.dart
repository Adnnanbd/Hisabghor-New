import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'services/database_service.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('products');
  await Hive.openBox('customers');
  await Hive.openBox('sales');
  await Hive.openBox('settings');
  await Hive.openBox('payments');

  // Initialize DB
  final db = DatabaseService();
  await db.init();

  runApp(const HisabghorApp());
}

class HisabghorApp extends StatelessWidget {
  const HisabghorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()..loadSaved()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadSaved()),
        Provider(create: (_) => DatabaseService()),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, lang, theme, _) {
          return MaterialApp(
            title: 'হিসাবঘর Pro',
            debugShowCheckedModeBanner: false,
            locale: lang.locale,
            themeMode: theme.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
