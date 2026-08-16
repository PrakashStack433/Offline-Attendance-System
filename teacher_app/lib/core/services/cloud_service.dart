import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudService {
  static const String _defaultBaseUrl = 'https://your-app.onrender.com';
  String? _baseUrl;

  String get baseUrl => _baseUrl ?? _defaultBaseUrl;

  void setBaseUrl(String url) {
    _baseUrl = url.replaceAll(RegExp(r'/+$'), '');
  }

  // --- Classes ---

  Future<Map<String, dynamic>?> createClass(String name) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/class'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getClass(String classId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/class/$classId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // --- Students ---

  Future<bool> addStudent({
    required String classId,
    required String studentId,
    required String name,
    required String enrollmentNo,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/class/$classId/student'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': studentId,
              'name': name,
              'enrollmentNo': enrollmentNo,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getStudents(String classId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/class/$classId/students'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['students'] ?? []);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // --- Attendance ---

  Future<List<Map<String, dynamic>>> getAttendance(
      String classId, {String? date}) async {
    try {
      var url = '$baseUrl/api/class/$classId/attendance';
      if (date != null) url += '?date=$date';

      final response = await http
          .get(Uri.parse(url))
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

  Future<bool> markAttendance({
    required String classId,
    required String studentId,
    required String name,
    required String enrollmentNo,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/class/$classId/attendance'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'studentId': studentId,
              'name': name,
              'enrollmentNo': enrollmentNo,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // --- Health ---

  Future<bool> healthCheck() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
