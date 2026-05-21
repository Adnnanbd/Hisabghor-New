import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import '../core/app_constants.dart';
import 'database_helper.dart';

class SaleLineInput {
  SaleLineInput({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.purchasePrice,
    required this.salePrice,
  });

  final int? productId;
  final String productName;
  final int quantity;
  final double purchasePrice;
  final double salePrice;
}

class PurchaseLineInput {
  PurchaseLineInput({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.purchasePrice,
    required this.barcode,
  });

  final int? productId;
  final String productName;
  final int quantity;
  final double purchasePrice;
  final String? barcode;
}

class DashboardSummary {
  const DashboardSummary({
    required this.todaySales,
    required this.todayExpense,
    required this.todayBalance,
    required this.totalDue,
    required this.monthlyBalance,
    required this.monthSales,
    required this.monthExpenses,
    required this.stockCount,
    required this.lowStockCount,
    required this.topDueCustomerName,
    required this.topDueCustomerAmount,
  });

  final double todaySales;
  final double todayExpense;
  final double todayBalance;
  final double totalDue;
  final double monthlyBalance;
  final double monthSales;
  final double monthExpenses;
  final int stockCount;
  final int lowStockCount;
  final String topDueCustomerName;
  final double topDueCustomerAmount;
}

class BusinessRepository {
  BusinessRepository(this._dbHelper);
  final DatabaseHelper _dbHelper;

  Future<Database> get _db => _dbHelper.database;

  static const exportableTables = [
    'users',
    'products',
    'customers',
    'sales',
    'sale_items',
    'purchases',
    'purchase_items',
    'due_payments',
    'expenses',
    'stock_transactions',
    'invoices',
    'app_settings',
  ];

  String hashPin(String pin) => sha256.convert(utf8.encode(pin)).toString();

  Future<bool> hasAdmin() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) AS c FROM users');
    return ((result.first['c'] as num?) ?? 0) > 0;
  }

  Future<int> createAdmin({
    required String name,
    required String phone,
    required String pin,
  }) async {
    final now = DateTime.now().toIso8601String();
    final db = await _db;
    return db.insert('users', {
      'name': name,
      'phone': phone,
      'pin_hash': hashPin(pin),
      'role': 'admin',
      'created_at': now,
      'updated_at': now,
      'is_synced': 0,
    });
  }

  Future<bool> login(String pin) async {
    final db = await _db;
    final rows = await db.query(
      'users',
      where: 'pin_hash = ?',
      whereArgs: [hashPin(pin)],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<DashboardSummary> dashboardSummary() async {
    final db = await _db;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrow = todayStart.add(const Duration(days: 1));
    final monthStart = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);

    final todaySales = await _sum(
      db,
      'sales',
      'total_amount',
      'sale_date >= ? AND sale_date < ?',
      [todayStart.toIso8601String(), tomorrow.toIso8601String()],
    );
    final todayExpenses = await _sum(
      db,
      'expenses',
      'amount',
      'expense_date >= ? AND expense_date < ?',
      [todayStart.toIso8601String(), tomorrow.toIso8601String()],
    );
    final totalDue = await _sum(db, 'customers', 'total_due', null, null);
    final monthProfit = await _sum(
      db,
      'sales',
      'profit',
      'sale_date >= ? AND sale_date < ?',
      [monthStart.toIso8601String(), nextMonth.toIso8601String()],
    );
    final monthSales = await _sum(
      db,
      'sales',
      'total_amount',
      'sale_date >= ? AND sale_date < ?',
      [monthStart.toIso8601String(), nextMonth.toIso8601String()],
    );
    final monthExpenses = await _sum(
      db,
      'expenses',
      'amount',
      'expense_date >= ? AND expense_date < ?',
      [monthStart.toIso8601String(), nextMonth.toIso8601String()],
    );

    final stockCountRows = await db.rawQuery(
      'SELECT COALESCE(SUM(current_stock), 0) AS total_stock FROM products WHERE is_active = 1',
    );
    final lowStockRows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM products WHERE is_active = 1 AND current_stock <= low_stock_alert',
    );
    final topDueRows = await db.query(
      'customers',
      where: 'total_due > 0',
      orderBy: 'total_due DESC',
      limit: 1,
    );
    final topDue = topDueRows.isEmpty ? null : topDueRows.first;

    return DashboardSummary(
      todaySales: todaySales,
      todayExpense: todayExpenses,
      todayBalance: todaySales - todayExpenses,
      totalDue: totalDue,
      monthlyBalance: monthProfit - monthExpenses,
      monthSales: monthSales,
      monthExpenses: monthExpenses,
      stockCount: ((stockCountRows.first['total_stock'] as num?) ?? 0).toInt(),
      lowStockCount: ((lowStockRows.first['c'] as num?) ?? 0).toInt(),
      topDueCustomerName: '${topDue?['name'] ?? 'নেই'}',
      topDueCustomerAmount: ((topDue?['total_due'] as num?) ?? 0).toDouble(),
    );
  }

  Future<double> _sum(
    Database db,
    String table,
    String column,
    String? where,
    List<Object?>? args,
  ) async {
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM($column), 0) AS total FROM $table${where == null ? '' : ' WHERE $where'}',
      args,
    );
    return (rows.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<List<Map<String, Object?>>> products({String? search}) async {
    final db = await _db;
    if (search == null || search.trim().isEmpty) {
      return db.query('products', where: 'is_active = 1', orderBy: 'name ASC');
    }
    final q = '%${search.trim()}%';
    return db.query(
      'products',
      where: 'is_active = 1 AND (name LIKE ? OR barcode LIKE ?)',
      whereArgs: [q, q],
      orderBy: 'name ASC',
    );
  }

  Future<List<Map<String, Object?>>> customers({String? search}) async {
    final db = await _db;
    if (search == null || search.trim().isEmpty) {
      return db.query('customers', orderBy: 'name ASC');
    }
    final q = '%${search.trim()}%';
    return db.query(
      'customers',
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: [q, q],
      orderBy: 'name ASC',
    );
  }

  Future<List<Map<String, Object?>>> dueCustomers({String? search}) async {
    final db = await _db;
    final q = '%${search?.trim() ?? ''}%';
    if (search == null || search.trim().isEmpty) {
      return db.query('customers', where: 'total_due > 0', orderBy: 'total_due DESC');
    }
    return db.query(
      'customers',
      where: 'total_due > 0 AND (name LIKE ? OR phone LIKE ?)',
      whereArgs: [q, q],
      orderBy: 'total_due DESC',
    );
  }

  Future<int> addOrMergeCustomer({
    required String name,
    required String phone,
    required String address,
    required double openingDue,
  }) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    if (phone.trim().isNotEmpty) {
      final existing = await db.query('customers', where: 'phone = ?', whereArgs: [phone.trim()], limit: 1);
      if (existing.isNotEmpty) {
        final row = existing.first;
        await db.update(
          'customers',
          {
            'name': name.trim().isEmpty ? row['name'] : name.trim(),
            'address': address.trim().isEmpty ? row['address'] : address.trim(),
            'updated_at': now,
            'is_synced': 0,
          },
          where: 'id = ?',
          whereArgs: [row['id']],
        );
        return row['id'] as int;
      }
    }

    return db.insert(
      'customers',
      {
        'name': name,
        'phone': phone.trim().isEmpty ? null : phone.trim(),
        'address': address,
        'opening_due': openingDue,
        'total_due': openingDue,
        'created_at': now,
        'updated_at': now,
        'is_synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> addCustomer({
    required String name,
    required String phone,
    required String address,
    required double openingDue,
  }) =>
      addOrMergeCustomer(
        name: name,
        phone: phone,
        address: address,
        openingDue: openingDue,
      );

  Future<int> addProduct({
    String? barcode,
    required String name,
    required double purchasePrice,
    required double salePrice,
    required int stock,
    required int lowStockAlert,
  }) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    return db.transaction((txn) async {
      final id = await txn.insert('products', {
        'barcode': barcode?.trim().isEmpty == true ? null : barcode?.trim(),
        'name': name,
        'purchase_price': purchasePrice,
        'sale_price': salePrice,
        'current_stock': stock,
        'low_stock_alert': lowStockAlert,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
        'is_synced': 0,
      });
      if (stock > 0) {
        await txn.insert('stock_transactions', {
          'product_id': id,
          'type': 'in',
          'quantity': stock,
          'purchase_price': purchasePrice,
          'sale_price': salePrice,
          'reason': 'প্রারম্ভিক স্টক',
          'transaction_date': now,
          'created_at': now,
          'updated_at': now,
          'is_synced': 0,
        });
      }
      return id;
    });
  }

  Future<void> upsertProduct({
    String? barcode,
    required String name,
    required double purchasePrice,
    required double salePrice,
    required int stock,
    required int lowStockAlert,
  }) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final existing = barcode != null && barcode.trim().isNotEmpty
        ? await db.query('products', where: 'barcode = ?', whereArgs: [barcode.trim()], limit: 1)
        : await db.query('products', where: 'name = ?', whereArgs: [name], limit: 1);
    if (existing.isEmpty) {
      await addProduct(
        barcode: barcode,
        name: name,
        purchasePrice: purchasePrice,
        salePrice: salePrice,
        stock: stock,
        lowStockAlert: lowStockAlert,
      );
      return;
    }
    final current = existing.first;
    final newStock = stock;
    await db.update(
      'products',
      {
        'barcode': barcode?.trim().isEmpty == true ? null : barcode?.trim(),
        'name': name,
        'purchase_price': purchasePrice,
        'sale_price': salePrice,
        'current_stock': newStock,
        'low_stock_alert': lowStockAlert,
        'updated_at': now,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [current['id']],
    );
  }

  Future<int> createPurchase({
    required String supplierName,
    required String supplierPhone,
    required double paidAmount,
    required List<PurchaseLineInput> lines,
    String note = '',
  }) async {
    if (lines.isEmpty) throw ArgumentError('অন্তত একটি পণ্য যোগ করুন');
    final db = await _db;
    final now = DateTime.now();
    final isoNow = now.toIso8601String();
    final invoiceNo = 'PUR${now.millisecondsSinceEpoch}';
    final totalAmount = lines.fold<double>(
      0,
      (sum, line) => sum + line.quantity * line.purchasePrice,
    );

    return db.transaction((txn) async {
      final purchaseId = await txn.insert('purchases', {
        'invoice_no': invoiceNo,
        'supplier_name': supplierName,
        'supplier_phone': supplierPhone,
        'total_amount': totalAmount,
        'paid_amount': paidAmount,
        'purchase_date': isoNow,
        'note': note,
        'created_at': isoNow,
        'updated_at': isoNow,
        'is_synced': 0,
      });

      for (final line in lines) {
        int productId = line.productId ?? 0;
        if (line.productId == null) {
          final found = line.barcode?.trim().isNotEmpty == true
              ? await txn.query('products', where: 'barcode = ?', whereArgs: [line.barcode!.trim()], limit: 1)
              : await txn.query('products', where: 'name = ?', whereArgs: [line.productName], limit: 1);
          if (found.isNotEmpty) {
            productId = found.first['id'] as int;
            await txn.rawUpdate(
              '''
              UPDATE products
              SET name = ?, purchase_price = ?, current_stock = current_stock + ?, updated_at = ?, is_synced = 0
              WHERE id = ?
              ''',
              [line.productName, line.purchasePrice, line.quantity, isoNow, productId],
            );
          } else {
            productId = await txn.insert('products', {
              'barcode': line.barcode?.trim().isEmpty == true ? null : line.barcode?.trim(),
              'name': line.productName,
              'purchase_price': line.purchasePrice,
              'sale_price': line.purchasePrice,
              'current_stock': line.quantity,
              'low_stock_alert': 5,
              'is_active': 1,
              'created_at': isoNow,
              'updated_at': isoNow,
              'is_synced': 0,
            });
          }
        } else {
          await txn.rawUpdate(
            '''
            UPDATE products
            SET purchase_price = ?, current_stock = current_stock + ?, updated_at = ?, is_synced = 0
            WHERE id = ?
            ''',
            [line.purchasePrice, line.quantity, isoNow, line.productId],
          );
          productId = line.productId!;
        }

        await txn.insert('purchase_items', {
          'purchase_id': purchaseId,
          'product_id': productId,
          'product_name': line.productName,
          'quantity': line.quantity,
          'purchase_price': line.purchasePrice,
          'line_total': line.purchasePrice * line.quantity,
          'is_synced': 0,
        });
        await txn.insert('stock_transactions', {
          'product_id': productId,
          'type': 'in',
          'quantity': line.quantity,
          'purchase_price': line.purchasePrice,
          'sale_price': null,
          'reason': 'ক্রয়',
          'transaction_date': isoNow,
          'created_at': isoNow,
          'updated_at': isoNow,
          'is_synced': 0,
        });
      }
      return purchaseId;
    });
  }

  Future<int> createSale({
    int? customerId,
    required String customerName,
    required String customerPhone,
    required double cashPaid,
    required List<SaleLineInput> lines,
  }) async {
    if (lines.isEmpty) throw ArgumentError('অন্তত একটি পণ্য যোগ করুন');
    final db = await _db;
    final now = DateTime.now();
    final isoNow = now.toIso8601String();
    final invoiceNo = 'SAL${now.millisecondsSinceEpoch}';
    final total = lines.fold<double>(0, (sum, line) => sum + line.quantity * line.salePrice);
    final profit = lines.fold<double>(
      0,
      (sum, line) => sum + line.quantity * (line.salePrice - line.purchasePrice),
    );
    final due = (total - cashPaid).clamp(0, double.infinity).toDouble();
    final paymentType = due <= 0 ? 'cash' : cashPaid <= 0 ? 'due' : 'partial';

    return db.transaction((txn) async {
      var effectiveCustomerId = customerId;
      if (effectiveCustomerId == null &&
          (customerName.trim().isNotEmpty || customerPhone.trim().isNotEmpty)) {
        final existing = customerPhone.trim().isEmpty
            ? <Map<String, Object?>>[]
            : await txn.query('customers', where: 'phone = ?', whereArgs: [customerPhone.trim()], limit: 1);
        if (existing.isNotEmpty) {
          effectiveCustomerId = existing.first['id'] as int;
        } else {
          effectiveCustomerId = await txn.insert('customers', {
            'name': customerName.trim().isEmpty ? 'নাম নেই' : customerName.trim(),
            'phone': customerPhone.trim().isEmpty ? null : customerPhone.trim(),
            'address': '',
            'opening_due': 0,
            'total_due': 0,
            'created_at': isoNow,
            'updated_at': isoNow,
            'is_synced': 0,
          });
        }
      }

      final saleId = await txn.insert('sales', {
        'invoice_no': invoiceNo,
        'customer_id': effectiveCustomerId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'total_amount': total,
        'cash_paid': cashPaid,
        'due_amount': due,
        'profit': profit,
        'payment_type': paymentType,
        'sale_date': isoNow,
        'note': '',
        'created_at': isoNow,
        'updated_at': isoNow,
        'is_synced': 0,
      });

      for (final line in lines) {
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_id': line.productId,
          'product_name': line.productName,
          'quantity': line.quantity,
          'purchase_price': line.purchasePrice,
          'sale_price': line.salePrice,
          'line_total': line.quantity * line.salePrice,
          'line_profit': line.quantity * (line.salePrice - line.purchasePrice),
          'is_synced': 0,
        });
        if (line.productId != null) {
          await txn.rawUpdate(
            'UPDATE products SET current_stock = current_stock - ?, updated_at = ?, is_synced = 0 WHERE id = ?',
            [line.quantity, isoNow, line.productId],
          );
          await txn.insert('stock_transactions', {
            'product_id': line.productId,
            'type': 'out',
            'quantity': line.quantity,
            'purchase_price': line.purchasePrice,
            'sale_price': line.salePrice,
            'reason': 'বিক্রয়',
            'transaction_date': isoNow,
            'created_at': isoNow,
            'updated_at': isoNow,
            'is_synced': 0,
          });
        }
      }

      if (effectiveCustomerId != null && due > 0) {
        await txn.rawUpdate(
          'UPDATE customers SET total_due = total_due + ?, updated_at = ?, is_synced = 0 WHERE id = ?',
          [due, isoNow, effectiveCustomerId],
        );
      }

      await txn.insert('invoices', {
        'sale_id': saleId,
        'invoice_no': invoiceNo,
        'pdf_path': '',
        'created_at': isoNow,
        'is_synced': 0,
      });
      return saleId;
    });
  }

  Future<int> recordDuePayment({
    required int customerId,
    required double amount,
    String note = '',
  }) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    return db.transaction((txn) async {
      final id = await txn.insert('due_payments', {
        'customer_id': customerId,
        'amount_paid': amount,
        'payment_date': now,
        'note': note,
        'created_at': now,
        'updated_at': now,
        'is_synced': 0,
      });
      await txn.rawUpdate(
        'UPDATE customers SET total_due = MAX(total_due - ?, 0), updated_at = ?, is_synced = 0 WHERE id = ?',
        [amount, now, customerId],
      );
      return id;
    });
  }

  Future<int> addExpense(String title, double amount, {String note = ''}) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    return db.insert('expenses', {
      'title': title,
      'amount': amount,
      'expense_date': now,
      'note': note,
      'created_at': now,
      'updated_at': now,
      'is_synced': 0,
    });
  }

  Future<void> stockChange({
    required int productId,
    required int quantity,
    required String type,
    required String reason,
  }) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final delta = type == 'in' ? quantity : -quantity;
    await db.transaction((txn) async {
      await txn.rawUpdate(
        'UPDATE products SET current_stock = current_stock + ?, updated_at = ?, is_synced = 0 WHERE id = ?',
        [delta, now, productId],
      );
      await txn.insert('stock_transactions', {
        'product_id': productId,
        'type': type,
        'quantity': quantity,
        'reason': reason,
        'transaction_date': now,
        'created_at': now,
        'updated_at': now,
        'is_synced': 0,
      });
    });
  }

  Future<List<Map<String, Object?>>> recentSales({int limit = 50}) async {
    final db = await _db;
    return db.query('sales', orderBy: 'sale_date DESC', limit: limit);
  }

  Future<List<Map<String, Object?>>> recentPurchases({int limit = 50}) async {
    final db = await _db;
    return db.query('purchases', orderBy: 'purchase_date DESC', limit: limit);
  }

  Future<List<Map<String, Object?>>> lowStockProducts() async {
    final db = await _db;
    return db.rawQuery(
      'SELECT * FROM products WHERE is_active = 1 AND current_stock <= low_stock_alert ORDER BY current_stock ASC',
    );
  }

  Future<Map<String, double>> reportTotals(DateTime from, DateTime to) async {
    final db = await _db;
    final start = from.toIso8601String();
    final end = to.toIso8601String();
    final sales = await _sum(db, 'sales', 'total_amount', 'sale_date >= ? AND sale_date < ?', [start, end]);
    final due = await _sum(db, 'sales', 'due_amount', 'sale_date >= ? AND sale_date < ?', [start, end]);
    final collection =
        await _sum(db, 'due_payments', 'amount_paid', 'payment_date >= ? AND payment_date < ?', [start, end]);
    final profit = await _sum(db, 'sales', 'profit', 'sale_date >= ? AND sale_date < ?', [start, end]);
    final expense = await _sum(db, 'expenses', 'amount', 'expense_date >= ? AND expense_date < ?', [start, end]);
    final purchase =
        await _sum(db, 'purchases', 'total_amount', 'purchase_date >= ? AND purchase_date < ?', [start, end]);
    return {
      'sales': sales,
      'due': due,
      'collection': collection,
      'profit': profit,
      'expense': expense,
      'purchase': purchase,
      'balance': profit - expense,
    };
  }

  Future<List<Map<String, Object?>>> recentExpenses({int limit = 30}) async {
    final db = await _db;
    return db.query('expenses', orderBy: 'expense_date DESC', limit: limit);
  }

  Future<List<Map<String, Object?>>> customerDueReport() async {
    final db = await _db;
    return db.query('customers', where: 'total_due > 0', orderBy: 'total_due DESC');
  }

  Future<List<Map<String, Object?>>> productSalesReport(DateTime from, DateTime to) async {
    final db = await _db;
    return db.rawQuery(
      '''
      SELECT product_name,
             SUM(quantity) AS quantity,
             SUM(line_total) AS total_sales,
             SUM(line_profit) AS total_profit
      FROM sale_items
      INNER JOIN sales ON sales.id = sale_items.sale_id
      WHERE sales.sale_date >= ? AND sales.sale_date < ?
      GROUP BY product_name
      ORDER BY total_sales DESC
      ''',
      [from.toIso8601String(), to.toIso8601String()],
    );
  }

  Future<List<Map<String, Object?>>> purchaseBook({int limit = 100}) async {
    final db = await _db;
    return db.query('purchases', orderBy: 'purchase_date DESC', limit: limit);
  }

  Future<List<Map<String, Object?>>> salesBook({int limit = 100}) async {
    final db = await _db;
    return db.query('sales', orderBy: 'sale_date DESC', limit: limit);
  }

  Future<List<Map<String, Object?>>> dueBook({int limit = 100}) async {
    final db = await _db;
    return db.rawQuery(
      '''
      SELECT due_payments.*, customers.name AS customer_name, customers.phone AS customer_phone
      FROM due_payments
      INNER JOIN customers ON customers.id = due_payments.customer_id
      ORDER BY payment_date DESC
      LIMIT ?
      ''',
      [limit],
    );
  }

  Future<List<Map<String, Object?>>> expensesBook({int limit = 100}) async {
    final db = await _db;
    return db.query('expenses', orderBy: 'expense_date DESC', limit: limit);
  }

  Future<List<Map<String, Object?>>> stockBook({int limit = 100}) async {
    final db = await _db;
    return db.rawQuery(
      '''
      SELECT stock_transactions.*, products.name AS product_name, products.barcode AS product_barcode
      FROM stock_transactions
      INNER JOIN products ON products.id = stock_transactions.product_id
      ORDER BY transaction_date DESC
      LIMIT ?
      ''',
      [limit],
    );
  }

  Future<String> setting(String key, {String defaultValue = ''}) async {
    final db = await _db;
    final rows = await db.query('app_settings', where: 'key = ?', whereArgs: [key], limit: 1);
    return rows.isEmpty ? defaultValue : '${rows.first['value']}';
  }

  Future<Map<String, String>> settings() async {
    final db = await _db;
    final rows = await db.query('app_settings');
    return {for (final row in rows) '${row['key']}': '${row['value']}'};
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    await db.insert(
      'app_settings',
      {
        'key': key,
        'value': value,
        'updated_at': now,
        'is_synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, Object?>>> exportRows(String table) async {
    final db = await _db;
    return db.query(table);
  }

  Future<void> importRows(String table, List<Map<String, Object?>> rows) async {
    if (rows.isEmpty) return;
    final db = await _db;
    final key = table == 'app_settings' ? 'key' : 'id';
    await db.transaction((txn) async {
      for (final row in rows) {
        final mutable = Map<String, Object?>.from(row);
        mutable['is_synced'] = 1;
        await txn.insert(
          table,
          mutable,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        if (mutable.containsKey(key)) {
          await txn.rawUpdate(
            'UPDATE $table SET is_synced = 1 WHERE $key = ?',
            [mutable[key]],
          );
        }
      }
    });
  }

  Future<Map<String, dynamic>> buildInstallEvent({
    required String adminName,
    required String adminPhone,
    required String shopName,
  }) async {
    final now = DateTime.now().toIso8601String();
    final adminHash = sha1.convert(utf8.encode('$adminName|$adminPhone|$now')).toString();
    return {
      'app_name': AppConstants.appName,
      'shop_name': shopName,
      'admin_name': adminName,
      'admin_phone': adminPhone,
      'app_version': '1.0.0',
      'package_name': 'com.hisabghor_busines.myapp',
      'created_at': now,
      'instance_key': adminHash,
      'target_email': 'adnnanrahman@gmail.com',
    };
  }
}
