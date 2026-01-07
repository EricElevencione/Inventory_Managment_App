// Empty State Widget - Shows when there's no data
// Provides visual feedback and action button for empty states

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A widget to display when a list or section has no data
///
/// Shows an icon, title, description, and optional action button
/// to help users understand and resolve the empty state.
class EmptyState extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Main title text
  final String title;

  /// Description text explaining the empty state
  final String description;

  /// Optional button text
  final String? buttonText;

  /// Optional callback when button is pressed
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppTheme.primaryColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            // Optional action button
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onButtonPressed,
                icon: const Icon(Icons.add),
                label: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined empty states for common scenarios
class EmptyStates {
  EmptyStates._();

  /// Empty state for no products
  static Widget noProducts({VoidCallback? onAddProduct}) {
    return EmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'No Products Yet',
      description:
          'Start building your inventory by adding your first product.',
      buttonText: 'Add Product',
      onButtonPressed: onAddProduct,
    );
  }

  /// Empty state for no search results
  static Widget noSearchResults({String? query}) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      description: query != null
          ? 'No products match "$query". Try a different search term.'
          : 'No products match your search. Try a different term.',
    );
  }

  /// Empty state for no low stock items
  static const Widget noLowStock = EmptyState(
    icon: Icons.check_circle_outline,
    title: 'All Stocked Up!',
    description: 'Great news! All your products are well-stocked.',
  );
}
