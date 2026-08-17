import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/date_utils.dart';

class ExportService {
  final AppDatabase _db;

  ExportService(this._db);

  Future<String> _getExportDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir.path;
  }

  Future<String> _getDownloadsDir() async {
    final dir = await getExternalStorageDirectory();
    if (dir != null) return dir.path;
    final docDir = await getApplicationDocumentsDirectory();
    return docDir.path;
  }

  Future<String> _generateCsv(String classId, String className) async {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    final records = await _db.attendanceDao.getAttendanceByDateRange(
      classId,
      start,
      end,
    );

    final rows = <List<String>>[];
    rows.add(['Roll Number', 'Student Name', 'Date', 'Status', 'Time']);

    for (final record in records) {
      rows.add([
        record.enrollmentNo,
        record.studentName,
        formatDate(record.date),
        record.status,
        formatTime(record.createdAt),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  Future<Uint8List> _generatePdfBytes(String classId, String className) async {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    final records = await _db.attendanceDao.getAttendanceByDateRange(
      classId,
      start,
      end,
    );

    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSansRegular();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Attendance Report - $className',
              style: pw.TextStyle(font: font, fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            'Generated: ${formatDateTime(DateTime.now())}',
            style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Period: ${formatDate(start)} to ${formatDate(end)}',
            style: pw.TextStyle(font: font, fontSize: 10),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Roll', 'Name', 'Date', 'Status', 'Time'],
            data: records.map((r) {
              return [
                r.enrollmentNo,
                r.studentName,
                formatDate(r.date),
                r.status,
                formatTime(r.createdAt),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
            cellStyle: pw.TextStyle(font: font, fontSize: 9),
            cellHeight: 25,
          ),
        ],
      ),
    );

    return await pdf.save();
  }

  Future<String> _generateTxt(String classId, String className) async {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    final records = await _db.attendanceDao.getAttendanceByDateRange(
      classId,
      start,
      end,
    );

    final buffer = StringBuffer();
    buffer.writeln('========================================');
    buffer.writeln('  ATTENDANCE REPORT');
    buffer.writeln('  Class: $className');
    buffer.writeln('  Generated: ${formatDateTime(DateTime.now())}');
    buffer.writeln('  Period: ${formatDate(start)} to ${formatDate(end)}');
    buffer.writeln('========================================');
    buffer.writeln();
    buffer.writeln('${'Roll'.padRight(8)}${'Name'.padRight(25)}${'Date'.padRight(14)}${'Status'.padRight(12)}Time');
    buffer.writeln('${'-' * 8}${'-' * 25}${'-' * 14}${'-' * 12}${'-' * 8}');

    for (final record in records) {
      buffer.writeln(
        '${record.enrollmentNo.padRight(8)}'
        '${record.studentName.padRight(25)}'
        '${formatDate(record.date).padRight(14)}'
        '${record.status.padRight(12)}'
        '${formatTime(record.createdAt)}',
      );
    }

    buffer.writeln();
    buffer.writeln('Total Records: ${records.length}');
    buffer.writeln('========================================');

    return buffer.toString();
  }

  Future<File> _saveToFile(String dirPath, String fileName, String content) async {
    final file = File('$dirPath/$fileName');
    await file.writeAsString(content);
    return file;
  }

  Future<File> _saveBytesToFile(String dirPath, String fileName, List<int> bytes) async {
    final file = File('$dirPath/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<String> saveCsvToDevice(String classId, String className) async {
    final csvData = await _generateCsv(classId, className);
    final downloadsDir = await _getDownloadsDir();
    final fileName = '${className}_attendance_${formatDate(DateTime.now())}.csv';
    final file = await _saveToFile(downloadsDir, fileName, csvData);
    return file.path;
  }

  Future<String> savePdfToDevice(String classId, String className) async {
    final pdfBytes = await _generatePdfBytes(classId, className);
    final downloadsDir = await _getDownloadsDir();
    final fileName = '${className}_attendance_${formatDate(DateTime.now())}.pdf';
    final file = await _saveBytesToFile(downloadsDir, fileName, pdfBytes);
    return file.path;
  }

  Future<String> saveTxtToDevice(String classId, String className) async {
    final txtData = await _generateTxt(classId, className);
    final downloadsDir = await _getDownloadsDir();
    final fileName = '${className}_attendance_${formatDate(DateTime.now())}.txt';
    final file = await _saveToFile(downloadsDir, fileName, txtData);
    return file.path;
  }

  Future<void> shareCsv(String classId, String className) async {
    final csvData = await _generateCsv(classId, className);
    final dirPath = await _getExportDir();
    final fileName = '${className}_attendance_${formatDate(DateTime.now())}.csv';
    final file = await _saveToFile(dirPath, fileName, csvData);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Attendance Report - $className',
    );
  }

  Future<void> sharePdf(String classId, String className) async {
    final pdfBytes = await _generatePdfBytes(classId, className);
    final dirPath = await _getExportDir();
    final fileName = '${className}_attendance_${formatDate(DateTime.now())}.pdf';
    final file = await _saveBytesToFile(dirPath, fileName, pdfBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Attendance Report - $className',
    );
  }

  Future<void> shareTxt(String classId, String className) async {
    final txtData = await _generateTxt(classId, className);
    final dirPath = await _getExportDir();
    final fileName = '${className}_attendance_${formatDate(DateTime.now())}.txt';
    final file = await _saveToFile(dirPath, fileName, txtData);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Attendance Report - $className',
    );
  }
}
