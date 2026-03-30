import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pos_server_client/pos_server_client.dart';
import 'package:intl/intl.dart';

class MenuPdfExport {
  static Future<void> exportMenu(
    List<Product> products,
    List<Category> categories,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'POS Menu Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text('Date: ${formatter.format(now)}'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Code', 'Name', 'Category', 'Price', 'Station', 'Type'],
              data: products.map((p) {
                final category = categories.firstWhere(
                  (c) => c.id == p.categoryId,
                  orElse: () => Category(name: '-', sortOrder: 0),
                );
                return [
                  p.itemCode ?? '-',
                  p.name,
                  category.name,
                  '\$${p.price.toStringAsFixed(2)}',
                  p.station ?? '-',
                  p.type ?? '-',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerLeft,
                5: pw.Alignment.centerLeft,
              },
            ),
            pw.SizedBox(height: 20),
            pw.Footer(
              trailing: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'menu_export_${now.millisecondsSinceEpoch}.pdf',
    );
  }
}
