// Product Model - Represents an inventory item
// Uses Hive for efficient local storage with type adapters

import 'package:hive/hive.dart';

// This annotation tells Hive to generate a TypeAdapter for this class
// Run: flutter packages pub run build_runner build
part 'product.g.dart';

/// Product model representing an inventory item
///
/// Each product has a unique ID, name, quantity, price, and category.
/// The [lowStockThreshold] determines when an item is considered "low stock".
@HiveType(typeId: 0)
class Product extends HiveObject {
  /// Unique identifier for the product
  @HiveField(0)
  final String id;

  /// Product name (e.g., "Blue T-Shirt", "Running Shoes")
  @HiveField(1)
  String name;

  /// Current quantity in stock
  @HiveField(2)
  int quantity;

  /// Price per unit in dollars
  @HiveField(3)
  double price;

  /// Product category (e.g., "Clothing", "Footwear", "Accessories")
  @HiveField(4)
  String category;

  /// Threshold below which the item is considered low stock
  @HiveField(5)
  int lowStockThreshold;

  /// Optional description for the product
  @HiveField(6)
  String? description;

  /// Date when the product was added to inventory
  @HiveField(7)
  DateTime createdAt;

  /// Date when the product was last updated
  @HiveField(8)
  DateTime updatedAt;

  /// Constructor with required and optional parameters
  Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
    this.lowStockThreshold = 10, // Default threshold
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Check if the product is low on stock
  bool get isLowStock => quantity <= lowStockThreshold;

  /// Check if the product is out of stock
  bool get isOutOfStock => quantity == 0;

  /// Calculate total value of this product in inventory
  double get totalValue => quantity * price;

  /// Create a copy of this product with updated fields
  Product copyWith({
    String? id,
    String? name,
    int? quantity,
    double? price,
    String? category,
    int? lowStockThreshold,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      category: category ?? this.category,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert product to a Map (useful for debugging or JSON export)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'category': category,
      'lowStockThreshold': lowStockThreshold,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a Product from a Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String,
      lowStockThreshold: map['lowStockThreshold'] as int? ?? 10,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, qty: $quantity, price: \$$price, category: $category)';
  }
}

/// Predefined product categories for the app
class ProductCategories {
  static const String clothing = 'Clothing';
  static const String footwear = 'Footwear';
  static const String accessories = 'Accessories';
  static const String electronics = 'Electronics';
  static const String homeGoods = 'Home & Garden';
  static const String sports = 'Sports & Outdoors';
  static const String other = 'Other';

  /// List of all available categories
  static List<String> get all => [
    clothing,
    footwear,
    accessories,
    electronics,
    homeGoods,
    sports,
    other,
  ];
}
