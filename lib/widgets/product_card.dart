// Product Card Widget - Displays a single product in a list
// Shows product details with visual indicators for stock status

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

/// A card widget that displays product information in a list
///
/// Shows product name, category, quantity, price, and visual
/// indicators for low stock or out of stock status.
class ProductCard extends StatelessWidget {
  /// The product to display
  final Product product;

  /// Callback when the card is tapped (for editing)
  final VoidCallback? onTap;

  /// Callback when delete is requested
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Currency formatter
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Name to badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product name
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Category chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stock status badge
                  _buildStockBadge(),
                ],
              ),
              const SizedBox(height: 12),
              // Divider
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Bottom row: Quantity, Price, Delete button
              Row(
                children: [
                  // Quantity
                  _buildInfoItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Qty',
                    value: product.quantity.toString(),
                    valueColor: AppTheme.getStockStatusColor(
                      product.quantity,
                      product.lowStockThreshold,
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Price
                  _buildInfoItem(
                    icon: Icons.attach_money,
                    label: 'Price',
                    value: currencyFormat.format(product.price),
                    valueColor: AppTheme.textPrimary,
                  ),
                  const SizedBox(width: 24),
                  // Total Value
                  _buildInfoItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Total',
                    value: currencyFormat.format(product.totalValue),
                    valueColor: AppTheme.secondaryColor,
                  ),
                  const Spacer(),
                  // Delete button
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppTheme.errorColor,
                      ),
                      onPressed: onDelete,
                      tooltip: 'Delete product',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the stock status badge (out of stock, low stock, or in stock)
  Widget _buildStockBadge() {
    String text;
    Color color;
    IconData icon;

    if (product.isOutOfStock) {
      text = 'Out of Stock';
      color = AppTheme.errorColor;
      icon = Icons.error_outline;
    } else if (product.isLowStock) {
      text = 'Low Stock';
      color = AppTheme.warningColor;
      icon = Icons.warning_amber_outlined;
    } else {
      text = 'In Stock';
      color = AppTheme.successColor;
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build an info item with icon, label, and value
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A compact list tile version for simpler lists
class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductListTile({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppTheme.getStockStatusColor(
          product.quantity,
          product.lowStockThreshold,
        ).withValues(alpha: 0.2),
        child: Icon(
          _getCategoryIcon(product.category),
          color: AppTheme.getStockStatusColor(
            product.quantity,
            product.lowStockThreshold,
          ),
        ),
      ),
      title: Text(
        product.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('${product.category} • Qty: ${product.quantity}'),
      trailing: Text(
        '\$${product.price.toStringAsFixed(2)}',
        style: AppTextStyles.price,
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Clothing':
        return Icons.checkroom;
      case 'Footwear':
        return Icons.directions_run;
      case 'Accessories':
        return Icons.watch;
      case 'Electronics':
        return Icons.devices;
      case 'Home & Garden':
        return Icons.home;
      case 'Sports & Outdoors':
        return Icons.sports_basketball;
      default:
        return Icons.inventory_2;
    }
  }
}
