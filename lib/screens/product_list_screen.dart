// Product List Screen - Displays all inventory items
// Features search, filtering, and low-stock highlighting

import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/empty_state.dart';
import 'add_edit_product_screen.dart';

/// Screen displaying all products in the inventory
///
/// Features:
/// - Search bar for filtering products
/// - Category filter chips
/// - Visual indicators for low/out of stock items
/// - Pull to refresh
/// - Swipe to delete
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Storage service instance
  final StorageService _storage = StorageService();

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Current search query
  String _searchQuery = '';

  // Selected category filter (null = all categories)
  String? _selectedCategory;

  // Sort option
  _SortOption _sortOption = _SortOption.name;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Get filtered and sorted products list
  List<Product> get _filteredProducts {
    List<Product> products = _storage.getAllProducts();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      products = products.where((product) {
        return product.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            product.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      products =
          products.where((p) => p.category == _selectedCategory).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case _SortOption.name:
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case _SortOption.price:
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case _SortOption.quantity:
        products.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case _SortOption.category:
        products.sort((a, b) => a.category.compareTo(b.category));
        break;
    }

    return products;
  }

  /// Get all unique categories from products
  List<String> get _categories {
    return _storage.getAllProducts().map((p) => p.category).toSet().toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // Sort button
          PopupMenuButton<_SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by',
            onSelected: (option) {
              setState(() {
                _sortOption = option;
              });
            },
            itemBuilder: (context) => [
              _buildSortMenuItem(_SortOption.name, 'Name'),
              _buildSortMenuItem(_SortOption.price, 'Price'),
              _buildSortMenuItem(_SortOption.quantity, 'Quantity'),
              _buildSortMenuItem(_SortOption.category, 'Category'),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          _buildSearchSection(),

          // Category filter chips
          if (_categories.isNotEmpty) _buildCategoryFilter(),

          // Products list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: _buildProductsList(),
            ),
          ),
        ],
      ),
      // Floating action button to add new product
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddProduct(),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  /// Build sort menu item with check mark for selected option
  PopupMenuItem<_SortOption> _buildSortMenuItem(
      _SortOption option, String label) {
    return PopupMenuItem(
      value: option,
      child: Row(
        children: [
          Icon(
            _sortOption == option ? Icons.check : null,
            size: 18,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  /// Build the search bar section
  Widget _buildSearchSection() {
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  /// Build category filter chips
  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: _selectedCategory == null,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = null;
                });
              },
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
            ),
          ),
          // Category chips
          ..._categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                  },
                  selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.primaryColor,
                ),
              )),
        ],
      ),
    );
  }

  /// Build the products list
  Widget _buildProductsList() {
    final products = _filteredProducts;

    if (products.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return EmptyStates.noSearchResults(query: _searchQuery);
      }
      return EmptyStates.noProducts(
        onAddProduct: () => _navigateToAddProduct(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: products.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          // Results count header
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              '${products.length} product${products.length != 1 ? 's' : ''} found',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          );
        }

        final product = products[index - 1];
        return Dismissible(
          key: Key(product.id),
          direction: DismissDirection.endToStart,
          background: _buildDismissBackground(),
          confirmDismiss: (direction) => _confirmDelete(product),
          onDismissed: (direction) => _deleteProduct(product),
          child: ProductCard(
            product: product,
            onTap: () => _navigateToEditProduct(product),
            onDelete: () => _showDeleteDialog(product),
          ),
        );
      },
    );
  }

  /// Build the swipe-to-delete background
  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.errorColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete, color: Colors.white),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to add product screen
  Future<void> _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditProductScreen(),
      ),
    );

    if (result == true) {
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  /// Navigate to edit product screen
  Future<void> _navigateToEditProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductScreen(product: product),
      ),
    );

    if (result == true) {
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteDialog(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.name}"?\n\nThis action cannot be undone.',
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteProduct(product);
    }
  }

  /// Confirm delete via swipe
  Future<bool> _confirmDelete(Product product) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Product'),
            content: Text('Delete "${product.name}"?'),
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
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Delete a product
  void _deleteProduct(Product product) {
    _storage.deleteProduct(product.id);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} deleted'),
        backgroundColor: AppTheme.errorColor,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () async {
            // Re-add the product (simplified undo)
            await _storage.addProduct(
              name: product.name,
              quantity: product.quantity,
              price: product.price,
              category: product.category,
              lowStockThreshold: product.lowStockThreshold,
              description: product.description,
            );
            setState(() {});
          },
        ),
      ),
    );
  }
}

/// Sort options enum
enum _SortOption {
  name,
  price,
  quantity,
  category,
}
