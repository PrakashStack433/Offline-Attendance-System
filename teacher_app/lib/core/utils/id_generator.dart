import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String generateId() => _uuid.v4();

String generateQrData({
  required String studentId,
  required String classId,
  required String rollNumber,
  required String studentName,
}) {
  final token = _uuid.v4();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return '$studentId|$classId|$rollNumber|$studentName|$token|$timestamp';
}
