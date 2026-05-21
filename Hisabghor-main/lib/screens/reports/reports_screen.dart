import 'package:flutter/material.dart';
import '../../utils/app_strings.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.reports),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCard(
            context,
            icon: Icons.today,
            title: AppStrings.dailyReport,
            subtitle: 'View today\'s sales and transactions',
          ),
          _buildReportCard(
            context,
            icon: Icons.calendar_month,
            title: AppStrings.monthlyReport,
            subtitle: 'Monthly sales summary',
          ),
          _buildReportCard(
            context,
            icon: Icons.shopping_cart,
            title: AppStrings.salesReport,
            subtitle: 'Detailed sales analysis',
          ),
          _buildReportCard(
            context,
            icon: Icons.payment,
            title: AppStrings.dueReport,
            subtitle: 'Customer due tracking',
          ),
          _buildReportCard(
            context,
            icon: Icons.show_chart,
            title: AppStrings.profitLossReport,
            subtitle: 'Profit and loss analysis',
          ),
          _buildReportCard(
            context,
            icon: Icons.inventory,
            title: AppStrings.stockReport,
            subtitle: 'Stock status and alerts',
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
