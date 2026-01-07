// Dashboard Screen - Main home screen with inventory overview
// Displays key metrics and quick access to inventory features

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/summary_card.dart';
import '../widgets/product_card.dart';

/// Dashboard screen showing inventory overview and statistics
///
/// Displays summary cards with total items, inventory value,
/// low stock alerts, and a list of items needing attention.
class DashboardScreen extends StatefulWidget {
  /// Callback to navigate to a specific tab
  final Function(int)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Storage service instance
  final StorageService _storage = StorageService();

  // Currency formatter
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              _buildHeader(),
              const SizedBox(height: 20),

              // Summary cards grid
              _buildSummaryCards(),
              const SizedBox(height: 24),

              // Quick stats row
              _buildQuickStats(),
              const SizedBox(height: 24),

              // Low stock alerts section
              _buildLowStockSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the welcome header section
  Widget _buildHeader() {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Inventory Overview',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Get greeting based on time of day
  String _getGreeting(int hour) {
    if (hour < 12) return 'Good morning! ☀️';
    if (hour < 17) return 'Good afternoon! 🌤️';
    return 'Good evening! 🌙';
  }

  /// Build the main summary cards grid
  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        // Total Products Card
        SummaryCard(
          title: 'Total Products',
          value: _storage.totalProductCount.toString(),
          icon: Icons.inventory_2,
          iconColor: AppTheme.primaryColor,
          subtitle: '${_storage.categoryCount} categories',
        ),

        // Inventory Value Card
        SummaryCard(
          title: 'Inventory Value',
          value: _currencyFormat.format(_storage.totalInventoryValue),
          icon: Icons.attach_money,
          iconColor: AppTheme.successColor,
          subtitle: 'Total stock value',
        ),

        // Low Stock Card
        SummaryCard(
          title: 'Low Stock',
          value: _storage.lowStockCount.toString(),
          icon: Icons.warning_amber,
          iconColor: AppTheme.warningColor,
          subtitle: 'Items need attention',
        ),

        // Out of Stock Card
        SummaryCard(
          title: 'Out of Stock',
          value: _storage.outOfStockCount.toString(),
          icon: Icons.error_outline,
          iconColor: AppTheme.errorColor,
          subtitle: 'Needs restocking',
        ),
      ],
    );
  }

  /// Build the quick stats row
  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickStatItem(
            icon: Icons.all_inbox,
            value: _storage.totalQuantity.toString(),
            label: 'Total Units',
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          _buildQuickStatItem(
            icon: Icons.category,
            value: _storage.categoryCount.toString(),
            label: 'Categories',
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          _buildQuickStatItem(
            icon: Icons.trending_up,
            value: _currencyFormat.format(
              _storage.totalInventoryValue /
                  (_storage.totalProductCount == 0
                      ? 1
                      : _storage.totalProductCount),
            ),
            label: 'Avg Value',
          ),
        ],
      ),
    );
  }

  /// Build individual quick stat item
  Widget _buildQuickStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  /// Build the low stock alerts section
  Widget _buildLowStockSection() {
    final lowStockProducts = _storage.getLowStockProducts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: AppTheme.warningColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Needs Attention',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            if (lowStockProducts.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Navigate to products tab
                  widget.onNavigateToTab?.call(1);
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Low stock products list
        if (lowStockProducts.isEmpty)
          _buildNoAlertsCard()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                lowStockProducts.length > 3 ? 3 : lowStockProducts.length,
            itemBuilder: (context, index) {
              final product = lowStockProducts[index];
              return _buildLowStockItem(product);
            },
          ),
      ],
    );
  }

  /// Build a card showing no alerts
  Widget _buildNoAlertsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.successColor.withValues(alpha: 0.3),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.check_circle,
            color: AppTheme.successColor,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'All products are well-stocked!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.successColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'No items need restocking at this time.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a low stock item row
  Widget _buildLowStockItem(Product product) {
    final isOutOfStock = product.isOutOfStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOutOfStock
            ? AppTheme.errorColor.withValues(alpha: 0.1)
            : AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOutOfStock
              ? AppTheme.errorColor.withValues(alpha: 0.3)
              : AppTheme.warningColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isOutOfStock
                  ? AppTheme.errorColor.withValues(alpha: 0.2)
                  : AppTheme.warningColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOutOfStock ? Icons.error : Icons.warning_amber,
              color: isOutOfStock ? AppTheme.errorColor : AppTheme.warningColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  product.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Quantity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isOutOfStock ? AppTheme.errorColor : AppTheme.warningColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isOutOfStock ? 'OUT' : 'Qty: ${product.quantity}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
