import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../core/formatters.dart';
import '../data/business_repository.dart';

class ExcelService {
  Future<String> exportMonthlyReport({
    required BusinessRepository repository,
    required DateTime from,
    required DateTime to,
    String languageCode = 'bn',
  }) async {
    final totals = await repository.reportTotals(from, to);
    final customerDues = await repository.customerDueReport();
    final productSales = await repository.productSalesReport(from, to);
    final stockBook = await repository.stockBook(limit: 200);

    final excel = Excel.createExcel();
    excel.rename('Sheet1', 'Summary');
    final summary = excel['Summary'];
    summary.appendRow([TextCellValue('Report'), TextCellValue('${Formatters.date(from, languageCode: languageCode)} - ${Formatters.date(to, languageCode: languageCode)}')]);
    summary.appendRow([TextCellValue('Sales'), TextCellValue(Formatters.money(totals['sales'] ?? 0, languageCode: languageCode))]);
    summary.appendRow([TextCellValue('Due'), TextCellValue(Formatters.money(totals['due'] ?? 0, languageCode: languageCode))]);
    summary.appendRow([TextCellValue('Collection'), TextCellValue(Formatters.money(totals['collection'] ?? 0, languageCode: languageCode))]);
    summary.appendRow([TextCellValue('Profit'), TextCellValue(Formatters.money(totals['profit'] ?? 0, languageCode: languageCode))]);
    summary.appendRow([TextCellValue('Expense'), TextCellValue(Formatters.money(totals['expense'] ?? 0, languageCode: languageCode))]);
    summary.appendRow([TextCellValue('Purchase'), TextCellValue(Formatters.money(totals['purchase'] ?? 0, languageCode: languageCode))]);
    summary.appendRow([TextCellValue('Balance'), TextCellValue(Formatters.money(totals['balance'] ?? 0, languageCode: languageCode))]);

    final dues = excel['Customer Due'];
    dues.appendRow([TextCellValue('Name'), TextCellValue('Phone'), TextCellValue('Address'), TextCellValue('Due')]);
    for (final row in customerDues) {
      dues.appendRow([
        TextCellValue('${row['name'] ?? ''}'),
        TextCellValue('${row['phone'] ?? ''}'),
        TextCellValue('${row['address'] ?? ''}'),
        TextCellValue('${row['total_due'] ?? 0}'),
      ]);
    }

    final products = excel['Product Sales'];
    products.appendRow([TextCellValue('Product'), TextCellValue('Quantity'), TextCellValue('Sales'), TextCellValue('Profit')]);
    for (final row in productSales) {
      products.appendRow([
        TextCellValue('${row['product_name'] ?? ''}'),
        TextCellValue('${row['quantity'] ?? 0}'),
        TextCellValue('${row['total_sales'] ?? 0}'),
        TextCellValue('${row['total_profit'] ?? 0}'),
      ]);
    }

    final stocks = excel['Stock Book'];
    stocks.appendRow([TextCellValue('Product'), TextCellValue('Type'), TextCellValue('Quantity'), TextCellValue('Reason'), TextCellValue('Date')]);
    for (final row in stockBook) {
      stocks.appendRow([
        TextCellValue('${row['product_name'] ?? ''}'),
        TextCellValue('${row['type'] ?? ''}'),
        TextCellValue('${row['quantity'] ?? 0}'),
        TextCellValue('${row['reason'] ?? ''}'),
        TextCellValue('${row['transaction_date'] ?? ''}'),
      ]);
    }

    final bytes = Uint8List.fromList(excel.encode() ?? <int>[]);
    return _saveBytes(
      fileName: 'hisabghor_business_report_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      bytes: bytes,
    );
  }

  Future<String> exportMonthlyReportCsv({
    required BusinessRepository repository,
    required DateTime from,
    required DateTime to,
  }) async {
    final totals = await repository.reportTotals(from, to);
    final rows = [
      ['metric', 'value'],
      ['sales', '${totals['sales'] ?? 0}'],
      ['due', '${totals['due'] ?? 0}'],
      ['collection', '${totals['collection'] ?? 0}'],
      ['profit', '${totals['profit'] ?? 0}'],
      ['expense', '${totals['expense'] ?? 0}'],
      ['purchase', '${totals['purchase'] ?? 0}'],
      ['balance', '${totals['balance'] ?? 0}'],
    ];
    final csvText = const ListToCsvConverter().convert(rows);
    return _saveBytes(
      fileName: 'hisabghor_business_report_${DateTime.now().millisecondsSinceEpoch}.csv',
      bytes: Uint8List.fromList(utf8.encode(csvText)),
    );
  }

  Future<String> exportStockTemplate() async {
    final excel = Excel.createExcel();
    excel.rename('Sheet1', 'Stock');
    excel['Stock'].appendRow([
      TextCellValue('barcode'),
      TextCellValue('name'),
      TextCellValue('purchase_price'),
      TextCellValue('sale_price'),
      TextCellValue('stock'),
      TextCellValue('low_stock_alert'),
    ]);
    final bytes = Uint8List.fromList(excel.encode() ?? <int>[]);
    return _saveBytes(fileName: 'hisabghor_stock_template.xlsx', bytes: bytes);
  }

  Future<int> importStock(BusinessRepository repository) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
      withData: true,
    );
    final file = picked?.files.single;
    if (file == null) return 0;
    if (file.bytes == null && file.path == null) return 0;
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final extension = file.extension?.toLowerCase();
    final rows = extension == 'csv' ? _readCsv(bytes) : _readXlsx(bytes);

    var imported = 0;
    for (final row in rows.skip(1)) {
      if (row.length < 2) continue;
      final name = row[1].trim();
      if (name.isEmpty) continue;
      await repository.upsertProduct(
        barcode: row.isNotEmpty ? row[0].trim() : '',
        name: name,
        purchasePrice: _number(row, 2),
        salePrice: _number(row, 3),
        stock: _number(row, 4).round(),
        lowStockAlert: _number(row, 5).round(),
      );
      imported++;
    }
    return imported;
  }

  List<List<String>> _readCsv(Uint8List bytes) {
    final text = utf8.decode(bytes);
    return const CsvToListConverter()
        .convert(text)
        .map((row) => row.map((cell) => '$cell').toList())
        .toList();
  }

  List<List<String>> _readXlsx(Uint8List bytes) {
    final workbook = Excel.decodeBytes(bytes);
    final sheet = workbook.tables.isEmpty ? null : workbook.tables.values.first;
    if (sheet == null) return [];
    return sheet.rows.map((row) => row.map((cell) => '${cell?.value ?? ''}').toList()).toList();
  }

  double _number(List<String> row, int index) {
    if (index >= row.length) return 0;
    return double.tryParse(row[index].replaceAll(',', '').trim()) ?? 0;
  }

  Future<String> _saveBytes({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final savedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'ফাইল সেভ করুন',
      fileName: fileName,
    );
    if (savedPath != null) {
      final file = File(savedPath);
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
