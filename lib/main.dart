import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// --- MODELS ---

class Product {
  String id;
  String name;
  double price;
  int stock;
  String category;

  Product({required this.id, required this.name, required this.price, required this.stock, this.category = 'General'});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'stock': stock,
        'category': category,
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'],
        name: map['name'],
        price: map['price'],
        stock: map['stock'],
        category: map['category'] ?? 'General',
      );
}

class Sale {
  String id;
  String productId;
  String productName;
  int quantity;
  double totalAmount;
  DateTime date;

  Sale({required this.id, required this.productId, required this.productName, required this.quantity, required this.totalAmount, required this.date});

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'totalAmount': totalAmount,
        'date': date.toIso8601String(),
      };

  factory Sale.fromMap(Map<String, dynamic> map) => Sale(
        id: map['id'],
        productId: map['productId'],
        productName: map['productName'],
        quantity: map['quantity'],
        totalAmount: map['totalAmount'],
        date: DateTime.parse(map['date']),
      );
}

class StoreSettings {
  String storeName;
  String phone;
  String address;

  StoreSettings({this.storeName = 'My Store', this.phone = '', this.address = ''});

  Map<String, dynamic> toMap() => {'storeName': storeName, 'phone': phone, 'address': address};

  factory StoreSettings.fromMap(Map<String, dynamic> map) => StoreSettings(
        storeName: map['storeName'] ?? 'My Store',
        phone: map['phone'] ?? '',
        address: map['address'] ?? '',
      );
}

// --- PROVIDERS ---

class AppData extends ChangeNotifier {
  List<Product> _products = [];
  List<Sale> _sales = [];
  StoreSettings _settings = StoreSettings();
  bool _isLoaded = false;

  List<Product> get products => _products;
  List<Sale> get sales => _sales;
  StoreSettings get settings => _settings;
  bool get isLoaded => _isLoaded;

  double get totalSales => _sales.fold(0, (sum, item) => sum + item.totalAmount);
  int get totalProducts => _products.length;
  int get lowStockCount => _products.where((p) => p.stock < 5).length;

  Future<void> loadData() async {
    await Hive.initFlutter();
    var productBox = await Hive.openBox('products');
    var salesBox = await Hive.openBox('sales');
    var settingsBox = await Hive.openBox('settings');

    _products = productBox.values.map((e) => Product.fromMap(e)).toList();
    _sales = salesBox.values.map((e) => Sale.fromMap(e)).toList();
    
    var settingsData = settingsBox.get('main', defaultValue: {});
    _settings = StoreSettings.fromMap(settingsData);

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    _products.add(product);
    var box = Hive.box('products');
    await box.put(product.id, product.toMap());
    notifyListeners();
  }

  Future<void> updateStock(String productId, int change) async {
    var index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index].stock += change;
      var box = Hive.box('products');
      await box.put(_products[index].id, _products[index].toMap());
      notifyListeners();
    }
  }

  Future<void> addSale(Sale sale) async {
    _sales.add(sale);
    await updateStock(sale.productId, -sale.quantity);
    var box = Hive.box('sales');
    await box.put(sale.id, sale.toMap());
    notifyListeners();
  }

  Future<void> saveSettings(StoreSettings newSettings) async {
    _settings = newSettings;
    var box = Hive.box('settings');
    await box.put('main', newSettings.toMap());
    notifyListeners();
  }
}

// --- MAIN APP ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppData())],
      child: const HisabghorApp(),
    ),
  );
}

class HisabghorApp extends StatelessWidget {
  const HisabghorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hisabghor Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.hindSiliguriTextTheme(),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const LoadingWrapper(),
    );
  }
}

class LoadingWrapper extends StatefulWidget {
  const LoadingWrapper({super.key});

  @override
  State<LoadingWrapper> createState() => _LoadingWrapperState();
}

class _LoadingWrapperState extends State<LoadingWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppData>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    if (!data.isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const MainScreen();
  }
}

// --- MAIN SCREEN WITH NAVIGATION ---

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ProductsPage(),
    const SalesPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Sales'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// --- DASHBOARD PAGE ---

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final settings = data.settings;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(settings.storeName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(settings.phone, style: const TextStyle(fontSize: 12)),
          ],
        ),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 40, color: Colors.green),
                    const SizedBox(height: 10),
                    Text('Total Sales', style: TextStyle(color: Colors.green.shade800)),
                    Text('৳ ${data.totalSales.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.inventory, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text('${data.totalProducts}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text('Products'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Card(
                    color: data.lowStockCount > 0 ? Colors.red.shade50 : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.warning, color: data.lowStockCount > 0 ? Colors.red : Colors.grey),
                          const SizedBox(height: 8),
                          Text('${data.lowStockCount}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text('Low Stock'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Recent Sales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            data.sales.isEmpty
                ? const Center(child: Text('No sales yet.'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.sales.length > 5 ? 5 : data.sales.length,
                    itemBuilder: (ctx, i) {
                      final sale = data.sales.reversed.toList()[i];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.receipt)),
                        title: Text(sale.productName),
                        subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(sale.date)),
                        trailing: Text('৳ ${sale.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

// --- PRODUCTS PAGE ---

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();

    return Scaffold(
      appBar: AppBar(title: const Text('Products'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: data.products.isEmpty
          ? const Center(child: Text('No products. Tap + to add.'))
          : ListView.builder(
              itemCount: data.products.length,
              itemBuilder: (ctx, i) {
                final p = data.products[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Stock: ${p.stock} | Price: ৳${p.price}'),
                    trailing: p.stock < 5 ? const Icon(Icons.warning, color: Colors.red) : null,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Product Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _stockCtrl, decoration: const InputDecoration(labelText: 'Initial Stock'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final prod = Product(
                      id: const Uuid().v4(),
                      name: _nameCtrl.text,
                      price: double.parse(_priceCtrl.text),
                      stock: int.parse(_stockCtrl.text),
                    );
                    context.read<AppData>().addProduct(prod);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Product'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- SALES PAGE ---

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();

    return Scaffold(
      appBar: AppBar(title: const Text('New Sale'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: data.products.isEmpty
          ? const Center(child: Text('Add products first!'))
          : ListView.builder(
              itemCount: data.products.length,
              itemBuilder: (ctx, i) {
                final p = data.products[i];
                if (p.stock <= 0) return const SizedBox.shrink();
                return Card(
                  child: ListTile(
                    title: Text(p.name),
                    subtitle: Text('Available: ${p.stock}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => _showSaleDialog(context, p),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showSaleDialog(BuildContext context, Product p) {
    final qtyCtrl = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sell ${p.name}'),
        content: TextField(
          controller: qtyCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantity'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(qtyCtrl.text) ?? 0;
              if (qty > 0 && qty <= p.stock) {
                final sale = Sale(
                  id: const Uuid().v4(),
                  productId: p.id,
                  productName: p.name,
                  quantity: qty,
                  totalAmount: qty * p.price,
                  date: DateTime.now(),
                );
                context.read<AppData>().addSale(sale);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale Recorded!')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid quantity')));
              }
            },
            child: const Text('Confirm Sale'),
          )
        ],
      ),
    );
  }
}

// --- SETTINGS PAGE ---

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = context.read<AppData>().settings;
    _nameCtrl.text = s.storeName;
    _phoneCtrl.text = s.phone;
    _addrCtrl.text = s.address;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Store Name')),
            TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
            TextField(controller: _addrCtrl, decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                final settings = StoreSettings(
                  storeName: _nameCtrl.text,
                  phone: _phoneCtrl.text,
                  address: _addrCtrl.text,
                );
                context.read<AppData>().saveSettings(settings);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings Saved!')));
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
            )
          ],
        ),
      ),
    );
  }
}
