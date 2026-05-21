import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'sales/sales_screen.dart';
import 'products/products_screen.dart';
import 'customers/customers_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SalesScreen(),
    const ProductsScreen(),
    const CustomersScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Sales'),
          NavigationDestination(icon: Icon(Icons.inventory), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Customers'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
