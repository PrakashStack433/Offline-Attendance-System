import 'dart:convert';
import 'package:http/http.dart' as http;

class ServerService {
  String? _serverUrl;

  void setServerUrl(String url) {
    _serverUrl = url.replaceAll(RegExp(r'/+$'), '');
  }

  String? get serverUrl => _serverUrl;

  Future<bool> healthCheck() async {
    if (_serverUrl == null) return false;
    try {
      final response = await http
          .get(Uri.parse('$_serverUrl/api/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAttendance({
    required String classId,
    required String className,
    required String studentId,
    required String name,
    required String enrollmentNo,
  }) async {
    if (_serverUrl == null) return false;
    try {
      final response = await http
          .post(
            Uri.parse('$_serverUrl/api/class/$classId/attendance'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'studentId': studentId,
              'name': name,
              'enrollmentNo': enrollmentNo,
              'className': className,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAttendanceHistory(
      String studentId) async {
    if (_serverUrl == null) return [];
    try {
      final response = await http
          .get(Uri.parse('$_serverUrl/api/student/$studentId/history'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['records'] ?? []);
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
