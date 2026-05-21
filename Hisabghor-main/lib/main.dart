import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Open boxes without adapters (using Map storage)
  await Hive.openBox('products');
  await Hive.openBox('customers');
  await Hive.openBox('sales');
  await Hive.openBox('settings');

  final db = DatabaseService();
  await db.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, languageProvider, themeProvider, child) {
          return MaterialApp(
            title: 'হিসাবঘর Pro',
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            theme: themeProvider.isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
