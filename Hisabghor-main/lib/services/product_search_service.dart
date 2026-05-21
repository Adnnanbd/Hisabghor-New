import '../models/product.dart';
import 'database_service.dart';

class ProductSearchService {
  final DatabaseService _db;

  ProductSearchService(this._db);

  Future<List<Product>> search(String query) async {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    final allProducts = await _db.getAllProducts();
    
    return allProducts.where((product) {
      final matchesBangla = product.nameBangla.toLowerCase().contains(lowerQuery);
      final matchesEnglish = product.nameEnglish.toLowerCase().contains(lowerQuery);
      final matchesBarcode = product.barcode?.contains(query) ?? false;
      
      return matchesBangla || matchesEnglish || matchesBarcode;
    }).toList();
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final allProducts = await _db.getAllProducts();
    try {
      return allProducts.firstWhere((p) => p.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  Future<void> decreaseStock(String productId, int quantity) async {
    final product = await _db.getProductById(productId);
    if (product != null) {
      await _db.updateProduct(product.copyWith(stockQuantity: product.stockQuantity - quantity));
    }
  }

  Future<void> increaseStock(String productId, int quantity) async {
    final product = await _db.getProductById(productId);
    if (product != null) {
      await _db.updateProduct(product.copyWith(stockQuantity: product.stockQuantity + quantity));
    }
  }
}
