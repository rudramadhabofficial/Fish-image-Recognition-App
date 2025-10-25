import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/fish_result.dart';

class PDFService {
  static Future<void> generateAndSharePDF(List<FishResult> results) async {
    try {
      // Pre-compute data to avoid doing it in the PDF build
      final tableData = _prepareTableData(results);
      
      final pdf = pw.Document();

      // Use a simpler, faster page layout
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Simple header - no complex decorations
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'FISH ANALYSIS REPORT',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Generated: ${DateTime.now().toString().split(' ')[0]}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 15),
                
                // Fast table generation
                _buildFastTable(tableData),
                pw.SizedBox(height: 10),
                
                // Simple summary
                pw.Text(
                  'Total records: ${results.length}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            );
          },
        ),
      );

      // Faster file operations
      final output = await getTemporaryDirectory();
      final filePath = '${output.path}/fish_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      // Save PDF directly without additional processing
      final pdfBytes = await pdf.save();
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // Share without waiting for completion
      unawaited(_sharePDF(filePath));

    } catch (e) {
      print('Fast PDF Generation Error: $e');
      rethrow;
    }
  }

  // Pre-compute table data to speed up PDF rendering
  static List<List<String>> _prepareTableData(List<FishResult> results) {
    final data = <List<String>>[];
    
    // Add header row
    data.add(['Species', 'Count', 'Confidence', 'Weight (g)', 'Health']);
    
    // Add data rows
    for (final result in results) {
      data.add([
        result.species,
        result.count.toString(),
        '${result.confidence.toStringAsFixed(1)}%',
        result.totalWeight.toStringAsFixed(1),
        result.healthStatus,
      ]);
    }
    
    return data;
  }

  // Fast table building without complex styling
  static pw.Widget _buildFastTable(List<List<String>> tableData) {
    return pw.TableHelper.fromTextArray(
      data: tableData,
      border: null, // No border for faster rendering
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      cellHeight: 20,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
      },
    );
  }

  // Separate sharing to avoid blocking
  static Future<void> _sharePDF(String filePath) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Fish Analysis Report',
      );
    } catch (e) {
      print('Sharing error: $e');
    }
  }
}

// Helper to avoid awaiting non-critical operations
void unawaited(Future<void> future) {
  // Intentionally not awaiting the future
}