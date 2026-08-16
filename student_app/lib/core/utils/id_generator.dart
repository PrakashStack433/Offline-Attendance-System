import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String generateId() => _uuid.v4();

String generateOfflineQrData({
  required String name,
  required String enrollmentNo,
  required String className,
}) {
  final date = DateTime.now();
  final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  final token = _uuid.v4().substring(0, 8);
  return 'OFFLINE|$name|$enrollmentNo|$className|$dateStr|$timeStr|$token';
}
