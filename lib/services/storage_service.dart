// Storage Service - Handles all data persistence using Hive
// Provides CRUD operations for Product inventory management

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';

/// Service class for managing product data persistence
///
/// Uses Hive as the underlying storage mechanism for fast,
/// lightweight local database operations.
class StorageService {
  // Singleton pattern for global access
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Box name constant
  static const String _productsBoxName = 'products';

  // UUID generator for unique product IDs
  final Uuid _uuid = const Uuid();

  // Hive box reference
  late Box<Product> _productsBox;

  /// Initialize Hive and open the products box
  /// Call this once at app startup
  Future<void> init() async {
    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register the Product adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }

    // Open the products box
    _productsBox = await Hive.openBox<Product>(_productsBoxName);

    // Pre-populate with sample data if empty (first launch)
    if (_productsBox.isEmpty) {
      await _populateSampleData();
    }
  }

  /// Get all products from storage
  List<Product> getAllProducts() {
    return _productsBox.values.toList();
  }

  /// Get a single product by ID
  Product? getProductById(String id) {
    try {
      return _productsBox.values.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new product to storage
  Future<Product> addProduct({
    required String name,
    required int quantity,
    required double price,
    required String category,
    int lowStockThreshold = 10,
    String? description,
  }) async {
    final product = Product(
      id: _uuid.v4(),
      name: name,
      quantity: quantity,
      price: price,
      category: category,
      lowStockThreshold: lowStockThreshold,
      description: description,
    );

    await _productsBox.put(product.id, product);
    return product;
  }

  /// Update an existing product
  Future<void> updateProduct(Product product) async {
    final updatedProduct = product.copyWith(updatedAt: DateTime.now());
    await _productsBox.put(product.id, updatedProduct);
  }

  /// Delete a product by ID
  Future<void> deleteProduct(String id) async {
    await _productsBox.delete(id);
  }

  /// Search products by name or category
  List<Product> searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    return _productsBox.values.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          product.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get products filtered by category
  List<Product> getProductsByCategory(String category) {
    return _productsBox.values
        .where((product) => product.category == category)
        .toList();
  }

  /// Get all products that are low on stock
  List<Product> getLowStockProducts() {
    return _productsBox.values.where((product) => product.isLowStock).toList();
  }

  /// Get all products that are out of stock
  List<Product> getOutOfStockProducts() {
    return _productsBox.values
        .where((product) => product.isOutOfStock)
        .toList();
  }

  // ============ Dashboard Statistics ============

  /// Get total number of products
  int get totalProductCount => _productsBox.length;

  /// Get total inventory value (sum of all products' total values)
  double get totalInventoryValue {
    return _productsBox.values
        .fold(0.0, (sum, product) => sum + product.totalValue);
  }

  /// Get count of low stock items
  int get lowStockCount {
    return _productsBox.values.where((p) => p.isLowStock).length;
  }

  /// Get count of out of stock items
  int get outOfStockCount {
    return _productsBox.values.where((p) => p.isOutOfStock).length;
  }

  /// Get total quantity of all items
  int get totalQuantity {
    return _productsBox.values
        .fold(0, (sum, product) => sum + product.quantity);
  }

  /// Get unique category count
  int get categoryCount {
    return _productsBox.values.map((p) => p.category).toSet().length;
  }

  /// Clear all data (useful for testing or reset)
  Future<void> clearAllData() async {
    await _productsBox.clear();
  }

  /// Pre-populate database with sample retail products
  Future<void> _populateSampleData() async {
    final sampleProducts = [
      Product(
        id: _uuid.v4(),
        name: 'Classic Blue T-Shirt',
        quantity: 45,
        price: 24.99,
        category: ProductCategories.clothing,
        lowStockThreshold: 10,
        description: 'Comfortable cotton t-shirt in classic blue',
      ),
      Product(
        id: _uuid.v4(),
        name: 'Slim Fit Jeans',
        quantity: 8, // Low stock!
        price: 59.99,
        category: ProductCategories.clothing,
        lowStockThreshold: 10,
        description: 'Modern slim fit denim jeans',
      ),
      Product(
        id: _uuid.v4(),
        name: 'Running Shoes Pro',
        quantity: 22,
        price: 89.99,
        category: ProductCategories.footwear,
        lowStockThreshold: 8,
        description: 'Professional running shoes with cushioned sole',
      ),
      Product(
        id: _uuid.v4(),
        name: 'Leather Wallet',
        quantity: 5, // Low stock!
        price: 34.99,
        category: ProductCategories.accessories,
        lowStockThreshold: 10,
        description: 'Genuine leather bifold wallet',
      ),
      Product(
        id: _uuid.v4(),
        name: 'Wireless Earbuds',
        quantity: 30,
        price: 79.99,
        category: ProductCategories.electronics,
        lowStockThreshold: 15,
        description: 'Bluetooth 5.0 wireless earbuds with charging case',
      ),
      Product(
        id: _uuid.v4(),
        name: 'Cotton Hoodie',
        quantity: 0, // Out of stock!
        price: 44.99,
        category: ProductCategories.clothing,
        lowStockThreshold: 8,
        description: 'Warm cotton blend hoodie',
      ),
      Product(
        id: _uuid.v4(),
        name: 'Canvas Backpack',
        quantity: 18,
        price: 49.99,
        category: ProductCategories.accessories,
        lowStockThreshold: 5,
        description: 'Durable canvas backpack with laptop compartment',
      ),
      Product(
        id: _uuid.v4(),
        name: 'Sports Watch',
        quantity: 12,
        price: 129.99,
        category: ProductCategories.electronics,
        lowStockThreshold: 5,
        description: 'Water-resistant sports watch with GPS',
      ),
      Product(
        id: _uuid.v4(),
        name: 'Yoga Mat Premium',
        quantity: 25,
        price: 29.99,
        category: ProductCategories.sports,
        lowStockThreshold: 10,
        description: 'Non-slip premium yoga mat',
      ),
      Product(
        id: _uuid.v4(),
        name: 'Sunglasses Classic',
        quantity: 3, // Low stock!
        price: 54.99,
        category: ProductCategories.accessories,
        lowStockThreshold: 8,
        description: 'UV protection classic style sunglasses',
      ),
    ];

    // Add all sample products to the database
    for (final product in sampleProducts) {
      await _productsBox.put(product.id, product);
    }
  }

  /// Close Hive boxes (call on app dispose if needed)
  Future<void> dispose() async {
    await _productsBox.close();
  }
}
