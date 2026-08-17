import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class TotpService {
  static const String _secret = 'OFFLINE_ATTENDANCE_TOTP_SECRET_2024';
  static const int _timeStep = 20;
  static const int _digits = 6;

  static String generateCode() {
    final counter = DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ _timeStep;
    return _generateHmac(counter);
  }

  static bool verifyCode(String code) {
    final currentCounter = DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ _timeStep;

    for (int i = -1; i <= 1; i++) {
      final expected = _generateHmac(currentCounter + i);
      if (code == expected) return true;
    }
    return false;
  }

  static String _generateCode(int counter) {
    return _generateHmac(counter);
  }

  static String _generateHmac(int counter) {
    final counterBytes = _intToBytes(counter);
    final secretBytes = utf8.encode(_secret);
    final hmac = Hmac(sha1, secretBytes);
    final digest = hmac.convert(counterBytes);

    final hash = digest.bytes;
    final offset = hash[hash.length - 1] & 0x0F;
    final binary = ((hash[offset] & 0x7F) << 24) |
        ((hash[offset + 1] & 0xFF) << 16) |
        ((hash[offset + 2] & 0xFF) << 8) |
        (hash[offset + 3] & 0xFF);

    final otp = binary % 1000000;
    return otp.toString().padLeft(_digits, '0');
  }

  static List<int> _intToBytes(int value) {
    final bytes = Uint8List(8);
    for (int i = 7; i >= 0; i--) {
      bytes[i] = value & 0xFF;
      value >>= 8;
    }
    return bytes;
  }

  static int get secondsUntilRefresh {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return _timeStep - (now % _timeStep);
  }
}
