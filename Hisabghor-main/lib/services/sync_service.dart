import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:sqflite/sqflite.dart';

import '../core/app_constants.dart';
import '../data/business_repository.dart';
import '../data/database_helper.dart';

class SyncService {
  SyncService(this._dbHelper, {required BusinessRepository repository})
      : _repository = repository;

  final DatabaseHelper _dbHelper;
  final BusinessRepository _repository;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
      sheets.SheetsApi.spreadsheetsScope,
    ],
    // Use the already signed-in Google account on the device for faster connection
    signInOption: SignInOption.standard,
  );

  static const Map<String, List<String>> _sheetHeaders = {
    'products': [
      'id',
      'barcode',
      'name',
      'purchase_price',
      'sale_price',
      'current_stock',
      'low_stock_alert',
      'is_active',
      'created_at',
      'updated_at',
      'is_synced',
    ],
    'customers': [
      'id',
      'name',
      'phone',
      'address',
      'opening_due',
      'total_due',
      'created_at',
      'updated_at',
      'is_synced',
    ],
    'sales': [
      'id',
      'invoice_no',
      'customer_id',
      'customer_name',
      'customer_phone',
      'total_amount',
      'cash_paid',
      'due_amount',
      'profit',
      'payment_type',
      'sale_date',
      'note',
      'created_at',
      'updated_at',
      'is_synced',
    ],
    'sale_items': [
      'id',
      'sale_id',
      'product_id',
      'product_name',
      'quantity',
      'purchase_price',
      'sale_price',
      'line_total',
      'line_profit',
      'is_synced',
    ],
    'purchases': [
      'id',
      'invoice_no',
      'supplier_name',
      'supplier_phone',
      'total_amount',
      'paid_amount',
      'purchase_date',
      'note',
      'created_at',
      'updated_at',
      'is_synced',
    ],
    'purchase_items': [
      'id',
      'purchase_id',
      'product_id',
      'product_name',
      'quantity',
      'purchase_price',
      'line_total',
      'is_synced',
    ],
    'due_payments': [
      'id',
      'customer_id',
      'amount_paid',
      'payment_date',
      'note',
      'created_at',
      'updated_at',
      'is_synced',
    ],
    'expenses': [
      'id',
      'title',
      'amount',
      'expense_date',
      'note',
      'created_at',
      'updated_at',
      'is_synced',
    ],
    'stock_transactions': [
      'id',
      'product_id',
      'type',
      'quantity',
      'purchase_price',
      'sale_price',
      'reason',
      'transaction_date',
      'created_at',
      'updated_at',
      'is_synced',
    ],
    'invoices': ['id', 'sale_id', 'invoice_no', 'pdf_path', 'created_at', 'is_synced'],
    'users': ['id', 'name', 'phone', 'pin_hash', 'role', 'created_at', 'updated_at', 'is_synced'],
    'app_settings': ['key', 'value', 'updated_at', 'is_synced'],
  };

  Future<bool> connectGoogleAccount() async {
    final result = await _googleAuthClient();
    return result != null;
  }

  Future<String> syncAll() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      return 'ইন্টারনেট সংযোগ নেই। ডেটা লোকাল ডাটাবেজে সংরক্ষিত আছে।';
    }

    await _repository.saveSetting('google_sync_status', 'syncing');
    await _repository.saveSetting('firebase_sync_status', 'syncing');

    final googleMessage = await _syncGoogleSheets();
    final firebaseMessage = await _syncFirebase();

    return 'Google Sheets: $googleMessage\nFirebase: $firebaseMessage';
  }

  Future<String> restoreFromSheet() async {
    final client = await _googleAuthClient();
    if (client == null) {
      await _repository.saveSetting('google_sync_status', 'needs_configuration');
      return 'Google account সাইন-ইন এখনো প্রস্তুত নয়। নতুন SHA / OAuth client দিয়ে google-services.json refresh করতে হবে।';
    }

    final driveApi = drive.DriveApi(client);
    final sheetsApi = sheets.SheetsApi(client);
    final spreadsheetId = await _findSpreadsheet(driveApi);
    if (spreadsheetId == null) {
      await _repository.saveSetting('google_sync_status', 'failed');
      return '${AppConstants.spreadsheetName} শিট পাওয়া যায়নি।';
    }

    final db = await _dbHelper.database;
    for (final entry in _sheetHeaders.entries) {
      await _restoreTable(db, sheetsApi, spreadsheetId, entry.key, entry.value);
    }
    await _repository.saveSetting('google_sync_status', 'success');
    return 'গুগল শিটস থেকে ডেটা রিস্টোর সম্পন্ন হয়েছে।';
  }

  Future<String> restoreFromFirebase() async {
    if (Firebase.apps.isEmpty) {
      await _repository.saveSetting('firebase_sync_status', 'needs_configuration');
      return 'Firebase configuration পাওয়া যায়নি।';
    }
    try {
      final settings = await _repository.settings();
      final ref = FirebaseDatabase.instance.ref('shops/${_shopKey(settings)}/tables');
      final snapshot = await ref.get().timeout(const Duration(seconds: 30));
      if (!snapshot.exists || snapshot.value is! Map) {
        await _repository.saveSetting('firebase_sync_status', 'failed');
        return 'Firebase backup পাওয়া যায়নি।';
      }
      final root = Map<Object?, Object?>.from(snapshot.value as Map);
      for (final table in _sheetHeaders.keys) {
        final rawRows = root[table];
        if (rawRows is! Map) continue;
        final rows = rawRows.values
            .map((value) => _firebaseValueToMap(value))
            .where((row) => row.isNotEmpty)
            .toList();
        await _repository.importRows(table, rows);
      }
      await _repository.saveSetting('firebase_sync_status', 'success');
      return 'Firebase থেকে ডেটা রিস্টোর সম্পন্ন হয়েছে।';
    } catch (error) {
      debugPrint('Firebase restore failed: $error');
      await _repository.saveSetting('firebase_sync_status', 'failed');
      return 'Firebase restore ব্যর্থ হয়েছে।';
    }
  }

  Future<void> registerInstallEventIfNeeded({
    required String adminName,
    required String adminPhone,
    required String shopName,
  }) async {
    final sent = await _repository.setting('install_event_sent', defaultValue: '0');
    if (sent == '1' || Firebase.apps.isEmpty) return;
    final event = await _repository.buildInstallEvent(
      adminName: adminName,
      adminPhone: adminPhone,
      shopName: shopName,
    );
    try {
      await FirebaseDatabase.instance
          .ref('${AppConstants.firebaseInstallEventsPath}/${event['instance_key']}')
          .set(event);
      await _repository.saveSetting('install_event_sent', '1');
    } catch (error) {
      debugPrint('Install event push failed: $error');
    }
  }

  Future<String> _syncGoogleSheets() async {
    try {
      final client = await _googleAuthClient();
      if (client == null) {
        await _repository.saveSetting('google_sync_status', 'needs_configuration');
        return 'sign-in blocked; OAuth / SHA setup still needed';
      }

      final driveApi = drive.DriveApi(client);
      final sheetsApi = sheets.SheetsApi(client);
      final spreadsheetId = await _getOrCreateSpreadsheet(driveApi, sheetsApi);
      if (spreadsheetId == null) {
        await _repository.saveSetting('google_sync_status', 'failed');
        return 'spreadsheet create failed';
      }
      final db = await _dbHelper.database;

      var syncedCount = 0;
      for (final entry in _sheetHeaders.entries) {
        syncedCount += await _syncTable(db, sheetsApi, spreadsheetId, entry.key, entry.value);
      }
      await _repository.saveSetting('google_sync_status', 'success');
      return '$syncedCount rows synced';
    } catch (error) {
      debugPrint('Google Sheets sync failed: $error');
      await _repository.saveSetting('google_sync_status', 'failed');
      return 'sync failed';
    }
  }

  Future<String> _syncFirebase() async {
    if (Firebase.apps.isEmpty) {
      await _repository.saveSetting('firebase_sync_status', 'needs_configuration');
      return 'Firebase config missing';
    }

    try {
      final settings = await _repository.settings();
      final tableRoot = FirebaseDatabase.instance.ref('shops/${_shopKey(settings)}/tables');
      var syncedRows = 0;
      for (final table in BusinessRepository.exportableTables) {
        final rows = await _repository.exportRows(table);
        final payload = <String, Object?>{};
        for (final row in rows) {
          final key = table == 'app_settings' ? '${row['key']}' : '${row['id']}';
          payload[key] = _normalizeFirebaseMap(row);
          syncedRows++;
        }
        await tableRoot.child(table).set(payload);
      }
      await FirebaseDatabase.instance.ref('shops/${_shopKey(settings)}/meta').update({
        'shop_name': settings['shop_name'] ?? AppConstants.defaultShopName,
        'updated_at': DateTime.now().toIso8601String(),
        'sync_targets': 'sqlite+google_sheets+firebase',
      });
      await _repository.saveSetting('firebase_sync_status', 'success');
      return '$syncedRows rows synced';
    } catch (error) {
      debugPrint('Firebase sync failed: $error');
      await _repository.saveSetting('firebase_sync_status', 'failed');
      return 'sync failed';
    }
  }

  Future<String?> _getOrCreateSpreadsheet(
    drive.DriveApi driveApi,
    sheets.SheetsApi sheetsApi,
  ) async {
    final existing = await _findSpreadsheet(driveApi);
    if (existing != null) {
      await _ensureSheets(sheetsApi, existing);
      return existing;
    }

    final file = drive.File()
      ..name = AppConstants.spreadsheetName
      ..mimeType = 'application/vnd.google-apps.spreadsheet';
    final created = await driveApi.files.create(file);
    final id = created.id;
    if (id == null) return null;
    await _ensureSheets(sheetsApi, id);
    return id;
  }

  Future<String?> _findSpreadsheet(drive.DriveApi driveApi) async {
    final result = await driveApi.files.list(
      q: "name = '${AppConstants.spreadsheetName}' and mimeType = 'application/vnd.google-apps.spreadsheet' and trashed = false",
      spaces: 'drive',
    );
    return result.files?.isNotEmpty == true ? result.files!.first.id : null;
  }

  Future<void> _ensureSheets(sheets.SheetsApi api, String spreadsheetId) async {
    final spreadsheet = await api.spreadsheets.get(spreadsheetId);
    final existingTitles = spreadsheet.sheets
            ?.map((sheet) => sheet.properties?.title)
            .whereType<String>()
            .toSet() ??
        <String>{};

    final requests = <sheets.Request>[];
    for (final title in _sheetHeaders.keys) {
      if (!existingTitles.contains(title)) {
        requests.add(
          sheets.Request()
            ..addSheet =
                (sheets.AddSheetRequest()..properties = (sheets.SheetProperties()..title = title)),
        );
      }
    }
    if (requests.isNotEmpty) {
      await api.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest()..requests = requests,
        spreadsheetId,
      );
    }

    for (final entry in _sheetHeaders.entries) {
      await api.spreadsheets.values.update(
        sheets.ValueRange()..values = [entry.value.cast<Object?>()],
        spreadsheetId,
        '${entry.key}!A1',
        valueInputOption: 'USER_ENTERED',
      );
    }
  }

  Future<int> _syncTable(
    Database db,
    sheets.SheetsApi api,
    String spreadsheetId,
    String table,
    List<String> columns,
  ) async {
    final rows = await db.query(table);
    await api.spreadsheets.values.clear(
      sheets.ClearValuesRequest(),
      spreadsheetId,
      '$table!A2:Z',
    );
    if (rows.isEmpty) return 0;

    final values = rows
        .map<List<Object?>>((row) => columns.map<Object?>((column) => row[column] ?? '').toList())
        .toList();

    await api.spreadsheets.values.update(
      sheets.ValueRange()..values = values,
      spreadsheetId,
      '$table!A2',
      valueInputOption: 'USER_ENTERED',
    );

    final idColumn = table == 'app_settings' ? 'key' : 'id';
    for (final row in rows) {
      await db.update(
        table,
        {'is_synced': 1},
        where: '$idColumn = ?',
        whereArgs: [row[idColumn]],
      );
    }
    return rows.length;
  }

  Future<void> _restoreTable(
    Database db,
    sheets.SheetsApi api,
    String spreadsheetId,
    String table,
    List<String> columns,
  ) async {
    final response = await api.spreadsheets.values.get(spreadsheetId, '$table!A2:Z');
    final values = response.values ?? [];
    final normalizedRows = <Map<String, Object?>>[];
    for (final row in values) {
      final map = <String, Object?>{};
      for (var i = 0; i < columns.length; i++) {
        map[columns[i]] = i < row.length ? _parseCell(row[i]) : null;
      }
      map['is_synced'] = 1;
      normalizedRows.add(map);
    }
    await _repository.importRows(table, normalizedRows);
  }

  Future<dynamic> _googleAuthClient() async {
    try {
      debugPrint('Starting Google sign-in process...');
      
      final account = _googleSignIn.currentUser ??
          await _googleSignIn.signIn().timeout(
                const Duration(seconds: 45),
                onTimeout: () {
                  debugPrint('Google sign-in timed out');
                  return null;
                },
              );
              
      if (account == null) {
        debugPrint('Google sign-in failed: account is null');
        return null;
      }
      
      debugPrint('Google sign-in successful for user: ${account.email}');
      
      final client = await _googleSignIn.authenticatedClient().timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('Getting authenticated client timed out');
              return null;
            },
          );
          
      if (client == null) {
        debugPrint('Failed to get authenticated client');
        return null;
      }
      
      debugPrint('Google authentication completed successfully');
      return client;
    } catch (error) {
      debugPrint('Google sign-in failed with error: $error');
      return null;
    }
  }

  String _shopKey(Map<String, String> settings) {
    final existing = settings['firebase_shop_key'];
    if (existing != null && existing.trim().isNotEmpty) return existing.trim();
    final base = (settings['shop_name'] ?? AppConstants.defaultShopName)
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return base.isEmpty ? 'default_shop' : base;
  }

  Map<String, Object?> _normalizeFirebaseMap(Map<String, Object?> row) {
    return row.map((key, value) => MapEntry(key, value is DateTime ? value.toIso8601String() : value));
  }

  Map<String, Object?> _firebaseValueToMap(Object? value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry('$key', val));
    }
    if (value is String) {
      try {
        final parsed = jsonDecode(value);
        if (parsed is Map) {
          return parsed.map((key, val) => MapEntry('$key', val));
        }
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  Object? _parseCell(Object? value) {
    if (value == null) return null;
    final string = '$value';
    if (string.isEmpty) return null;
    if (RegExp(r'^-?\d+$').hasMatch(string)) {
      return int.tryParse(string) ?? string;
    }
    if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(string)) {
      return double.tryParse(string) ?? string;
    }
    return string;
  }
}
