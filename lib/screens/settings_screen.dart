// Settings Screen - App configuration and about section
// Includes options for data management and app info

import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Settings screen with app configuration options
///
/// Features:
/// - Reset sample data
/// - Clear all data
/// - About section with app info
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Data Management Section
          _buildSectionHeader('Data Management'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.refresh,
              iconColor: AppTheme.primaryColor,
              title: 'Reset Sample Data',
              subtitle: 'Restore original sample products',
              onTap: () => _showResetDialog(),
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.delete_forever,
              iconColor: AppTheme.errorColor,
              title: 'Clear All Data',
              subtitle: 'Delete all products permanently',
              onTap: () => _showClearDialog(),
            ),
          ]),
          const SizedBox(height: 24),

          // App Info Section
          _buildSectionHeader('About'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.inventory_2,
              iconColor: AppTheme.primaryColor,
              title: 'Inventory Manager',
              subtitle: 'Version 1.0.0',
              onTap: () => _showAboutDialog(),
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.code,
              iconColor: AppTheme.secondaryColor,
              title: 'Built with Flutter',
              subtitle: 'Cross-platform mobile app',
              onTap: null,
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.storage,
              iconColor: AppTheme.warningColor,
              title: 'Local Storage',
              subtitle: 'Powered by Hive database',
              onTap: null,
            ),
          ]),
          const SizedBox(height: 24),

          // Statistics Section
          _buildSectionHeader('Quick Stats'),
          const SizedBox(height: 8),
          _buildStatsCard(),
          const SizedBox(height: 32),

          // Footer
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2,
                  size: 48,
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inventory Management App',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'A Portfolio Project',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    );
  }

  /// Build settings card container
  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: children,
      ),
    );
  }

  /// Build individual settings tile
  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: AppTheme.textSecondary)
          : null,
      onTap: onTap,
    );
  }

  /// Build statistics card
  Widget _buildStatsCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              label: 'Products',
              value: _storage.totalProductCount.toString(),
              icon: Icons.inventory_2,
            ),
            Container(
              height: 40,
              width: 1,
              color: const Color(0xFFE2E8F0),
            ),
            _buildStatItem(
              label: 'Categories',
              value: _storage.categoryCount.toString(),
              icon: Icons.category,
            ),
            Container(
              height: 40,
              width: 1,
              color: const Color(0xFFE2E8F0),
            ),
            _buildStatItem(
              label: 'Low Stock',
              value: _storage.lowStockCount.toString(),
              icon: Icons.warning_amber,
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual stat item
  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Show reset data confirmation dialog
  Future<void> _showResetDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Sample Data'),
        content: const Text(
          'This will clear all current data and restore the original sample products.\n\nDo you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.clearAllData();
      // Re-initialize to populate sample data
      await _storage.init();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample data restored successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  /// Show clear all data confirmation dialog
  Future<void> _showClearDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppTheme.errorColor),
            SizedBox(width: 8),
            Text('Clear All Data'),
          ],
        ),
        content: const Text(
          'This will permanently delete ALL products from your inventory.\n\nThis action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.clearAllData();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// Show about dialog
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.inventory_2,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Inventory Manager'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A professional inventory management application built with Flutter.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('• Dashboard with inventory overview'),
            Text('• Product management (CRUD)'),
            Text('• Search and filter products'),
            Text('• Low stock alerts'),
            Text('• Local data persistence'),
            SizedBox(height: 16),
            Text(
              'Built as a portfolio project demonstrating Flutter development skills.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
