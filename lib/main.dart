import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

// --- ENTRY POINT ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HisabghorApp());
}

// --- APP WIDGET ---
class HisabghorApp extends StatelessWidget {
  const HisabghorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppData()),
      ],
      child: MaterialApp(
        title: 'Hisabghor Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          fontFamily: 'Roboto', // Fallback font to prevent crash
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

// --- MODELS ---
class Product {
  String id;
  String name;
  double price;
  int stock;
  String category;

  Product({required this.id, required this.name, required this.price, required this.stock, this.category = 'General'});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'stock': stock,
        'category': category,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        price: json['price'].toDouble(),
        stock: json['stock'],
        category: json['category'] ?? 'General',
      );
}

class Sale {
  String id;
  String productId;
  String productName;
  int quantity;
  double totalAmount;
  DateTime date;
  String customerName;

  Sale({required this.id, required this.productId, required this.productName, required this.quantity, required this.totalAmount, required this.date, this.customerName = 'Walk-in'});

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'totalAmount': totalAmount,
        'date': date.toIso8601String(),
        'customerName': customerName,
      };

  factory Sale.fromJson(Map<String, dynamic> json) => Sale(
        id: json['id'],
        productId: json['productId'],
        productName: json['productName'],
        quantity: json['quantity'],
        totalAmount: json['totalAmount'].toDouble(),
        date: DateTime.parse(json['date']),
        customerName: json['customerName'] ?? 'Walk-in',
      );
}

// --- STATE MANAGEMENT ---
class AppData extends ChangeNotifier {
  List<Product> _products = [];
  List<Sale> _sales = [];
  String _storeName = 'My Store';
  String _storePhone = '';
  String _storeAddress = '';
  bool _isLoading = true;
  String? _error;

  List<Product> get products => _products;
  List<Sale> get sales => _sales;
  String get storeName => _storeName;
  String get storePhone => _storePhone;
  String get storeAddress => _storeAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalSales => _sales.fold(0, (sum, item) => sum + item.totalAmount);
  int get totalProducts => _products.length;
  int get lowStockCount => _products.where((p) => p.stock < 5).length;

  Future<void> loadData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      
      // Load Store Info
      _storeName = prefs.getString('storeName') ?? 'My Store';
      _storePhone = prefs.getString('storePhone') ?? '';
      _storeAddress = prefs.getString('storeAddress') ?? '';

      // Load Products
      final productsJson = prefs.getStringList('products') ?? [];
      _products = productsJson.map((e) => Product.fromJson(jsonDecode(e))).toList();

      // Load Sales
      final salesJson = prefs.getStringList('sales') ?? [];
      _sales = salesJson.map((e) => Sale.fromJson(jsonDecode(e))).toList();

      _error = null;
    } catch (e) {
      _error = "Failed to load data: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveStoreInfo(String name, String phone, String address) async {
    _storeName = name;
    _storePhone = phone;
    _storeAddress = address;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('storeName', name);
    await prefs.setString('storePhone', phone);
    await prefs.setString('storeAddress', address);
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    _products.add(product);
    await _saveProducts();
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      await _saveProducts();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    await _saveProducts();
    notifyListeners();
  }

  Future<void> recordSale(Sale sale) async {
    _sales.insert(0, sale); // Add to top
    // Reduce stock
    final productIndex = _products.indexWhere((p) => p.id == sale.productId);
    if (productIndex != -1) {
      _products[productIndex].stock -= sale.quantity;
      await _saveProducts();
    }
    
    final prefs = await SharedPreferences.getInstance();
    final salesJson = _sales.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('sales', salesJson);
    
    notifyListeners();
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = _products.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('products', productsJson);
  }
}

// --- SCREENS ---

// 1. Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      final appData = Provider.of<AppData>(context, listen: false);
      await appData.loadData();
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store, size: 80, color: Colors.white),
              SizedBox(height: 20),
              Text('Hisabghor Pro', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. Main Screen with Navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductsScreen(),
    const SalesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.point_of_sale), label: 'Sales'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// 3. Dashboard
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);

    if (appData.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appData.error != null) {
      return Center(child: Text("Error: ${appData.error}"));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appData.storeName),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Welcome to ${appData.storeName}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (appData.storePhone.isNotEmpty) Text("📞 ${appData.storePhone}"),
                    if (appData.storeAddress.isNotEmpty) Text("📍 ${appData.storeAddress}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _StatCard("Total Sales", "৳${appData.totalSales.toStringAsFixed(0)}", Icons.attach_money, Colors.blue),
                _StatCard("Products", "${appData.totalProducts}", Icons.inventory, Colors.orange),
                _StatCard("Low Stock", "${appData.lowStockCount}", Icons.warning, Colors.red),
                _StatCard("Today's Sales", "${appData.sales.where((s) => s.date.day == DateTime.now().day).length}", Icons.trending_up, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _StatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

// 4. Products Screen
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  void _showProductDialog({Product? product}) {
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final priceCtrl = TextEditingController(text: product?.price.toString() ?? '');
    final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '');
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
            TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newProduct = Product(
                id: product?.id ?? DateTime.now().toString(),
                name: nameCtrl.text,
                price: double.tryParse(priceCtrl.text) ?? 0,
                stock: int.tryParse(stockCtrl.text) ?? 0,
              );
              if (product == null) {
                Provider.of<AppData>(context, listen: false).addProduct(newProduct);
              } else {
                Provider.of<AppData>(context, listen: false).updateProduct(newProduct);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Products'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: appData.products.isEmpty 
        ? const Center(child: Text('No products yet. Tap + to add.'))
        : ListView.builder(
            itemCount: appData.products.length,
            itemBuilder: (_, i) {
              final p = appData.products[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text('Price: ৳${p.price} | Stock: ${p.stock}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _showProductDialog(product: p)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => appData.deleteProduct(p.id)),
                  ],
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// 5. Sales Screen
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  void _recordSale() {
    final appData = Provider.of<AppData>(context, listen: false);
    if (appData.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add products first!')));
      return;
    }

    String? selectedProductId;
    final qtyCtrl = TextEditingController(text: '1');
    final customerCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Sale'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Product'),
                items: appData.products.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.name} (Stock: ${p.stock})'))).toList(),
                onChanged: (val) => setDialogState(() => selectedProductId = val),
              ),
              TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
              TextField(controller: customerCtrl, decoration: const InputDecoration(labelText: 'Customer Name (Optional)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (selectedProductId == null) return;
                final product = appData.products.firstWhere((p) => p.id == selectedProductId);
                final qty = int.tryParse(qtyCtrl.text) ?? 1;
                
                if (qty > product.stock) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough stock!')));
                  return;
                }

                final sale = Sale(
                  id: DateTime.now().toString(),
                  productId: product.id,
                  productName: product.name,
                  quantity: qty,
                  totalAmount: product.price * qty,
                  date: DateTime.now(),
                  customerName: customerCtrl.text.isEmpty ? 'Walk-in' : customerCtrl.text,
                );
                appData.recordSale(sale);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale recorded!'), backgroundColor: Colors.green));
              },
              child: const Text('Complete Sale'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sales History'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: appData.sales.isEmpty
        ? const Center(child: Text('No sales recorded yet.'))
        : ListView.builder(
            itemCount: appData.sales.length,
            itemBuilder: (_, i) {
              final s = appData.sales[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.shopping_bag)),
                  title: Text(s.productName),
                  subtitle: Text('${s.customerName} • ${DateFormat('yyyy-MM-dd HH:mm').format(s.date)}'),
                  trailing: Text('৳${s.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recordSale,
        child: const Icon(Icons.add_shopping_cart),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// 6. Settings Screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addrCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final appData = Provider.of<AppData>(context, listen: false);
    nameCtrl.text = appData.storeName;
    phoneCtrl.text = appData.storePhone;
    addrCtrl.text = appData.storeAddress;
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Store Name', prefixIcon: Icon(Icons.store))),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone))),
            const SizedBox(height: 10),
            TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                appData.saveStoreInfo(nameCtrl.text, phoneCtrl.text, addrCtrl.text);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved!'), backgroundColor: Colors.green));
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 20),
            const Text("Data is saved locally on this device.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
