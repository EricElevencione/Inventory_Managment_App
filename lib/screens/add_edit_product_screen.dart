// Add/Edit Product Screen - Form for creating or updating products
// Includes validation, category selection, and image placeholder

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

/// Screen for adding a new product or editing an existing one
///
/// Features:
/// - Form validation for all required fields
/// - Category dropdown selection
/// - Number inputs for quantity, price, and threshold
/// - Real-time validation feedback
class AddEditProductScreen extends StatefulWidget {
  /// Product to edit (null for adding new product)
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  /// Whether we're editing an existing product
  bool get isEditing => product != null;

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Storage service
  final StorageService _storage = StorageService();

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _thresholdController;
  late TextEditingController _descriptionController;

  // Selected category
  late String _selectedCategory;

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing product data or defaults
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _quantityController = TextEditingController(
      text: product?.quantity.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    _thresholdController = TextEditingController(
      text: product?.lowStockThreshold.toString() ?? '10',
    );
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _selectedCategory = product?.category ?? ProductCategories.clothing;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _thresholdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Validate and save the product
  Future<void> _saveProduct() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final quantity = int.parse(_quantityController.text.trim());
      final price = double.parse(_priceController.text.trim());
      final threshold = int.parse(_thresholdController.text.trim());
      final description = _descriptionController.text.trim();

      if (widget.isEditing) {
        // Update existing product
        final updatedProduct = widget.product!.copyWith(
          name: name,
          quantity: quantity,
          price: price,
          category: _selectedCategory,
          lowStockThreshold: threshold,
          description: description.isEmpty ? null : description,
        );
        await _storage.updateProduct(updatedProduct);
      } else {
        // Add new product
        await _storage.addProduct(
          name: name,
          quantity: quantity,
          price: price,
          category: _selectedCategory,
          lowStockThreshold: threshold,
          description: description.isEmpty ? null : description,
        );
      }

      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Product' : 'Add Product'),
        actions: [
          // Save button in app bar
          if (!_isLoading)
            TextButton(
              onPressed: _saveProduct,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product icon/image placeholder
                    _buildProductIcon(),
                    const SizedBox(height: 24),

                    // Product Name
                    _buildNameField(),
                    const SizedBox(height: 16),

                    // Category dropdown
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),

                    // Price and Quantity row
                    Row(
                      children: [
                        Expanded(child: _buildPriceField()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildQuantityField()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Low stock threshold
                    _buildThresholdField(),
                    const SizedBox(height: 16),

                    // Description
                    _buildDescriptionField(),
                    const SizedBox(height: 24),

                    // Preview card
                    _buildPreviewCard(),
                    const SizedBox(height: 24),

                    // Save button
                    _buildSaveButton(),
                    const SizedBox(height: 16),

                    // Cancel button
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Build product icon placeholder
  Widget _buildProductIcon() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Icon(
          _getCategoryIcon(_selectedCategory),
          size: 48,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  /// Get icon for category
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

  /// Build product name field
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Product Name *',
        hintText: 'e.g., Blue T-Shirt, Running Shoes',
        prefixIcon: Icon(Icons.label_outline),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a product name';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  /// Build category dropdown
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category *',
        prefixIcon: Icon(Icons.category_outlined),
      ),
      items: ProductCategories.all.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 20,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(category),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  /// Build price field
  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: const InputDecoration(
        labelText: 'Price *',
        hintText: '0.00',
        prefixIcon: Icon(Icons.attach_money),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Enter price';
        }
        final price = double.tryParse(value.trim());
        if (price == null || price < 0) {
          return 'Invalid price';
        }
        return null;
      },
    );
  }

  /// Build quantity field
  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      decoration: const InputDecoration(
        labelText: 'Quantity *',
        hintText: '0',
        prefixIcon: Icon(Icons.inventory_2_outlined),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Enter qty';
        }
        final qty = int.tryParse(value.trim());
        if (qty == null || qty < 0) {
          return 'Invalid qty';
        }
        return null;
      },
    );
  }

  /// Build low stock threshold field
  Widget _buildThresholdField() {
    return TextFormField(
      controller: _thresholdController,
      decoration: const InputDecoration(
        labelText: 'Low Stock Threshold',
        hintText: '10',
        prefixIcon: Icon(Icons.warning_amber_outlined),
        helperText: 'Alert when quantity falls at or below this number',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final threshold = int.tryParse(value.trim());
          if (threshold == null || threshold < 0) {
            return 'Invalid threshold';
          }
        }
        return null;
      },
    );
  }

  /// Build description field
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Add a description for this product...',
        prefixIcon: Icon(Icons.description_outlined),
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      maxLength: 200,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  /// Build preview card showing how the product will look
  Widget _buildPreviewCard() {
    final name = _nameController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final threshold = int.tryParse(_thresholdController.text.trim()) ?? 10;

    if (name.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.getStockStatusColor(quantity, threshold)
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(_selectedCategory),
                  color: AppTheme.getStockStatusColor(quantity, threshold),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_selectedCategory • Qty: $quantity',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            AppTheme.getStockStatusColor(quantity, threshold),
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: AppTextStyles.price,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build save button
  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _saveProduct,
      icon: Icon(widget.isEditing ? Icons.save : Icons.add),
      label: Text(widget.isEditing ? 'Update Product' : 'Add Product'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
