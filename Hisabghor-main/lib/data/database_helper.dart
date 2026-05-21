import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../core/app_constants.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _version = 2;
  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseFileName);
    _database = await openDatabase(
      path,
      version: _version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _create,
      onUpgrade: _upgrade,
    );
    return _database!;
  }

  Future<void> _create(Database db, int version) async {
    await _createCoreTables(db);
    await _seed(db);
  }

  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createPurchasesTables(db);
      await _ensureSetting(db, 'shop_name', AppConstants.defaultShopName);
      await _ensureSetting(db, 'app_language', 'bn');
      await _ensureSetting(db, 'theme_mode', 'system');
      await _ensureSetting(db, 'google_sync_status', 'pending');
      await _ensureSetting(db, 'firebase_sync_status', 'pending');
      await _ensureSetting(db, 'install_event_sent', '0');
    }
  }

  Future<void> _createCoreTables(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        pin_hash TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'admin',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT UNIQUE,
        name TEXT NOT NULL,
        purchase_price REAL NOT NULL DEFAULT 0,
        sale_price REAL NOT NULL DEFAULT 0,
        current_stock INTEGER NOT NULL DEFAULT 0,
        low_stock_alert INTEGER NOT NULL DEFAULT 5,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT UNIQUE,
        address TEXT,
        opening_due REAL NOT NULL DEFAULT 0,
        total_due REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_no TEXT NOT NULL UNIQUE,
        customer_id INTEGER,
        customer_name TEXT,
        customer_phone TEXT,
        total_amount REAL NOT NULL,
        cash_paid REAL NOT NULL,
        due_amount REAL NOT NULL,
        profit REAL NOT NULL,
        payment_type TEXT NOT NULL,
        sale_date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(customer_id) REFERENCES customers(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        purchase_price REAL NOT NULL,
        sale_price REAL NOT NULL,
        line_total REAL NOT NULL,
        line_profit REAL NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(sale_id) REFERENCES sales(id) ON DELETE CASCADE,
        FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE SET NULL
      )
    ''');

    await _createPurchasesTables(db);

    await db.execute('''
      CREATE TABLE due_payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        amount_paid REAL NOT NULL,
        payment_date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(customer_id) REFERENCES customers(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        expense_date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE stock_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        purchase_price REAL,
        sale_price REAL,
        reason TEXT,
        transaction_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        invoice_no TEXT NOT NULL,
        pdf_path TEXT,
        created_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(sale_id) REFERENCES sales(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        row_id INTEGER NOT NULL,
        operation TEXT NOT NULL,
        created_at TEXT NOT NULL,
        last_error TEXT
      )
    ''');
  }

  Future<void> _createPurchasesTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS purchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_no TEXT NOT NULL UNIQUE,
        supplier_name TEXT,
        supplier_phone TEXT,
        total_amount REAL NOT NULL,
        paid_amount REAL NOT NULL,
        purchase_date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS purchase_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_id INTEGER NOT NULL,
        product_id INTEGER,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        purchase_price REAL NOT NULL,
        line_total REAL NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(purchase_id) REFERENCES purchases(id) ON DELETE CASCADE,
        FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE SET NULL
      )
    ''');
  }

  Future<void> _seed(Database db) async {
    final now = DateTime.now().toIso8601String();
    final seeds = <Map<String, Object?>>[
      {
        'key': 'developer_details',
        'value': AppConstants.developerDetails,
        'updated_at': now,
        'is_synced': 0,
      },
      {
        'key': 'shop_name',
        'value': AppConstants.defaultShopName,
        'updated_at': now,
        'is_synced': 0,
      },
      {
        'key': 'app_language',
        'value': 'bn',
        'updated_at': now,
        'is_synced': 0,
      },
      {
        'key': 'theme_mode',
        'value': 'system',
        'updated_at': now,
        'is_synced': 0,
      },
      {
        'key': 'google_sync_status',
        'value': 'pending',
        'updated_at': now,
        'is_synced': 0,
      },
      {
        'key': 'firebase_sync_status',
        'value': 'pending',
        'updated_at': now,
        'is_synced': 0,
      },
      {
        'key': 'install_event_sent',
        'value': '0',
        'updated_at': now,
        'is_synced': 0,
      },
    ];
    for (final row in seeds) {
      await db.insert('app_settings', row, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _ensureSetting(Database db, String key, String value) async {
    final now = DateTime.now().toIso8601String();
    await db.insert(
      'app_settings',
      {'key': key, 'value': value, 'updated_at': now, 'is_synced': 0},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
