import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Preferences'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(AppStrings.darkMode),
                  subtitle: const Text('Toggle dark/light theme'),
                  value: themeProvider.isDark,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text(AppStrings.language),
                  subtitle: Text(languageProvider.currentLanguage),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    languageProvider.toggleLanguage();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Data Management'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_upload),
                  title: const Text(AppStrings.backup),
                  subtitle: const Text('Backup data to cloud'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_download),
                  title: const Text(AppStrings.restore),
                  subtitle: const Text('Restore from backup'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text(AppStrings.about),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text(AppStrings.developer),
                  subtitle: const Text(AppStrings.developerName),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text(AppStrings.contact),
                  subtitle: const Text(AppStrings.adminEmail),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text(AppStrings.logout),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  void showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.about),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('হিসাবঘর Pro'),
            const SizedBox(height: 8),
            const Text('Smart Store Management Solution'),
            const SizedBox(height: 16),
            Text('Developer: ${AppStrings.developerName}'),
            Text('Email: ${AppStrings.adminEmail}'),
            Text('WhatsApp: ${AppStrings.whatsappSupport}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform logout
            },
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }
}
