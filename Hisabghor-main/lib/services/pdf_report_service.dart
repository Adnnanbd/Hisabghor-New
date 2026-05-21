import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/app_constants.dart';
import '../core/formatters.dart';

class PdfReportService {
  Future<void> printSummaryReport({
    required String title,
    required DateTime from,
    required DateTime to,
    required Map<String, double> totals,
    String shopName = AppConstants.defaultShopName,
    String languageCode = 'bn',
  }) async {
    final font = await PdfGoogleFonts.notoSansBengaliRegular();
    final bold = await PdfGoogleFonts.notoSansBengaliBold();
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Theme(
            data: pw.ThemeData.withFont(base: font, bold: bold),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(shopName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('${Formatters.date(from, languageCode: languageCode)} - ${Formatters.date(to, languageCode: languageCode)}'),
                pw.Divider(),
                _row('Sales', totals['sales'] ?? 0, languageCode),
                _row('Due', totals['due'] ?? 0, languageCode),
                _row('Collection', totals['collection'] ?? 0, languageCode),
                _row('Profit', totals['profit'] ?? 0, languageCode),
                _row('Expense', totals['expense'] ?? 0, languageCode),
                _row('Purchase', totals['purchase'] ?? 0, languageCode),
                _row('Balance', totals['balance'] ?? 0, languageCode),
                pw.Spacer(),
                pw.Divider(),
                pw.Text(AppConstants.developerDetails, style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  pw.Widget _row(String label, double amount, String languageCode) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(Formatters.money(amount, languageCode: languageCode)),
        ],
      ),
    );
  }
}
