import 'package:uuid/uuid.dart';
import '../services/totp_service.dart';

const _uuid = Uuid();

String generateId() => _uuid.v4();

String generateOfflineQrData({
  required String name,
  required String enrollmentNo,
  required String className,
}) {
  final date = DateTime.now();
  final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  final totpCode = TotpService.generateCode();
  return 'OFFLINE|$name|$enrollmentNo|$dateStr|$timeStr|$totpCode';
}
