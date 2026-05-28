import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart' show Share;
import 'package:cross_file/cross_file.dart';// for XFile
import 'package:pdf/widgets.dart' as pw;

class ReportService {
  // save PDF to device documents folder
  static Future<File> saveToDevice(
      pw.Document doc, String fileName) async {
    final bytes = await doc.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  // open system print dialog
  static Future<void> print(pw.Document doc) async {
    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
    );
  }

  // share via WhatsApp, email etc
  static Future<void> share(File file, String infantName) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'BaalShravya Screening Report — $infantName',
    );
  }
}