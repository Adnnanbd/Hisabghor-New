import 'package:hive/hive.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';

class DatabaseService {
  late Box _productBox;
  late Box _customerBox;
  late Box _saleBox;

  Future<void> init() async {
    _productBox = Hive.box('products');
    _customerBox = Hive.box('customers');
    _saleBox = Hive.box('sales');
  }

  // --- Product Methods ---
  Future<List<Product>> getAllProducts() async {
    return _productBox.values.map((e) => Product.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<Product?> getProductById(String id) async {
    final data = _productBox.get(id);
    if (data == null) return null;
    return Product.fromMap(data as Map<String, dynamic>);
  }

  Future<void> addProduct(Product product) async {
    await _productBox.put(product.id, product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _productBox.put(product.id, product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _productBox.delete(id);
  }

  Future<List<Product>> searchProducts(String query) async {
    final lowerQuery = query.toLowerCase();
    return _productBox.values.map((e) => Product.fromMap(e as Map<String, dynamic>)).where((product) {
      return product.nameBangla.toLowerCase().contains(lowerQuery) ||
          product.nameEnglish.toLowerCase().contains(lowerQuery) ||
          (product.barcode != null && product.barcode!.contains(query));
    }).toList();
  }

  Future<void> updateStock(String productId, int quantityChange) async {
    final product = await getProductById(productId);
    if (product != null) {
      final newStock = product.stockQuantity + quantityChange;
      if (newStock >= 0) {
        await updateProduct(product.copyWith(stockQuantity: newStock));
      }
    }
  }

  // --- Customer Methods ---
  Future<List<Customer>> getAllCustomers() async {
    return _customerBox.values.map((e) => Customer.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> addCustomer(Customer customer) async {
    await _customerBox.put(customer.id, customer.toMap());
  }

  Future<void> updateCustomer(Customer customer) async {
    await _customerBox.put(customer.id, customer.toMap());
  }

  Future<void> deleteCustomer(String id) async {
    await _customerBox.delete(id);
  }

  // --- Sale Methods ---
  Future<List<Sale>> getAllSales() async {
    return _saleBox.values.map((e) => Sale.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> addSale(Sale sale) async {
    await _saleBox.put(sale.id, sale);
    
    // Update stock for each item
    for (var item in sale.items) {
      await updateStock(item.productId, -item.quantity);
    }

    // Update customer due if any
    if (sale.dueAmount > 0) {
      final customer = _customerBox.get(sale.customerId);
      if (customer != null) {
        final updatedDue = customer.dueAmount + sale.dueAmount;
        await _customerBox.put(customer.id, customer.copyWith(dueAmount: updatedDue));
      }
    }
  }
  
  double getTotalDue() {
    double total = 0;
    for (var customer in _customerBox.values) {
      total += customer.dueAmount;
    }
    return total;
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final products = await getAllProducts();
    final sales = await getAllSales();

    // Calculate today's sales
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    double todaySales = 0;
    for (var sale in sales) {
      if (sale.saleDate.isAtSameMomentAs(todayStart) || sale.saleDate.isAfter(todayStart)) {
        todaySales += sale.grandTotal;
      }
    }

    // Calculate total due from all customers
    double totalDue = getTotalDue();

    // Calculate monthly profit (simplified: total sales - total cost)
    double monthlyProfit = 0;
    for (var sale in sales) {
      monthlyProfit += sale.totalProfit;
    }

    // Calculate stock value
    double stockValue = 0;
    for (var product in products) {
      stockValue += product.buyPrice * product.stockQuantity;
    }

    // Count low stock products
    int lowStockProducts = products.where((p) => p.stockQuantity <= 5).length;

    return {
      'todaySales': todaySales,
      'totalDue': totalDue,
      'monthlyProfit': monthlyProfit,
      'stockValue': stockValue,
      'lowStockProducts': lowStockProducts,
    };
  }
}
