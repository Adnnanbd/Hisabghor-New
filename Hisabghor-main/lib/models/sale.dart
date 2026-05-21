class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double buyPrice;
  final double sellPrice;
  final double total;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.buyPrice,
    required this.sellPrice,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'total': total,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      buyPrice: (map['buyPrice'] ?? 0).toDouble(),
      sellPrice: (map['sellPrice'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
    );
  }
}

class Sale {
  final String id;
  final String invoiceNumber;
  final List<SaleItem> items;
  final String customerId;
  final String customerName;
  final double subTotal;
  final double discount;
  final double vatPercent;
  final double vatAmount;
  final double grandTotal;
  final double paidAmount;
  final double dueAmount;
  final double totalProfit;
  final DateTime saleDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String notes;

  Sale({
    required this.id,
    required this.invoiceNumber,
    required this.items,
    required this.customerId,
    required this.customerName,
    required this.subTotal,
    this.discount = 0,
    this.vatPercent = 0,
    this.vatAmount = 0,
    required this.grandTotal,
    required this.paidAmount,
    required this.dueAmount,
    required this.totalProfit,
    required this.saleDate,
    required this.createdAt,
    required this.updatedAt,
    this.notes = '',
  });

  // Getter to fix the error
  double get totalAmount => grandTotal;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'items': items.map((item) => item.toMap()).toList(),
      'customerId': customerId,
      'customerName': customerName,
      'subTotal': subTotal,
      'discount': discount,
      'vatPercent': vatPercent,
      'vatAmount': vatAmount,
      'grandTotal': grandTotal,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'totalProfit': totalProfit,
      'saleDate': saleDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      items: (map['items'] as List<dynamic>)
          .map((item) => SaleItem.fromMap(item))
          .toList(),
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      subTotal: (map['subTotal'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      vatPercent: (map['vatPercent'] ?? 0).toDouble(),
      vatAmount: (map['vatAmount'] ?? 0).toDouble(),
      grandTotal: (map['grandTotal'] ?? 0).toDouble(),
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      dueAmount: (map['dueAmount'] ?? 0).toDouble(),
      totalProfit: (map['totalProfit'] ?? 0).toDouble(),
      saleDate: DateTime.parse(map['saleDate']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      notes: map['notes'] ?? '',
    );
  }
}
