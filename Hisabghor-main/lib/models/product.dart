class Product {
  String id;
  String nameBangla;
  String nameEnglish;
  String? barcode;
  double buyPrice;
  double sellPrice;
  int stockQuantity;
  int minStock;
  String? category;
  String? unit;
  DateTime? createdAt;
  DateTime? updatedAt;

  Product({
    required this.id,
    required this.nameBangla,
    required this.nameEnglish,
    this.barcode,
    required this.buyPrice,
    required this.sellPrice,
    required this.stockQuantity,
    this.minStock = 5,
    this.category,
    this.unit,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Getter for display name (prefers Bangla)
  String get displayName => nameBangla.isNotEmpty ? nameBangla : nameEnglish;

  // Getter for low stock status
  bool get isLowStock => stockQuantity <= minStock;

  // Getter for out of stock status
  bool get isOutOfStock => stockQuantity == 0;

  // CopyWith method for immutability
  Product copyWith({
    String? id,
    String? nameBangla,
    String? nameEnglish,
    String? barcode,
    double? buyPrice,
    double? sellPrice,
    int? stockQuantity,
    int? minStock,
    String? category,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      nameBangla: nameBangla ?? this.nameBangla,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      barcode: barcode ?? this.barcode,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStock: minStock ?? this.minStock,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameBangla': nameBangla,
      'nameEnglish': nameEnglish,
      'barcode': barcode,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'stockQuantity': stockQuantity,
      'minStock': minStock,
      'category': category,
      'unit': unit,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      nameBangla: map['nameBangla'] ?? '',
      nameEnglish: map['nameEnglish'] ?? '',
      barcode: map['barcode'],
      buyPrice: (map['buyPrice'] ?? 0).toDouble(),
      sellPrice: (map['sellPrice'] ?? 0).toDouble(),
      stockQuantity: map['stockQuantity'] ?? 0,
      minStock: map['minStock'] ?? 5,
      category: map['category'],
      unit: map['unit'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  @override
  String toString() => displayName;
}
