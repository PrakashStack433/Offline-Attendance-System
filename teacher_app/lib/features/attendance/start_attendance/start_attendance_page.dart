import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/cloud_service.dart';

class StartAttendancePage extends StatefulWidget {
  final String classId;
  final String className;

  const StartAttendancePage({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<StartAttendancePage> createState() => _StartAttendancePageState();
}

class _StartAttendancePageState extends State<StartAttendancePage> {
  late CloudService _cloud;
  bool _isConnected = false;
  int _onlineCount = 0;
  Timer? _refreshTimer;
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cloud = context.read<CloudService>();
    _urlController.text = _cloud.baseUrl;
    _checkConnection();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    _cloud.setBaseUrl(_urlController.text.trim());
    final connected = await _cloud.healthCheck();
    if (mounted) {
      setState(() => _isConnected = connected);
      if (connected) _startRefreshTimer();
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      final records = await _cloud.getAttendance(widget.classId);
      if (mounted) {
        setState(() => _onlineCount = records.length);
        await _syncRecordsToLocalDb(records);
      }
    });
  }

  Future<void> _syncRecordsToLocalDb(List<Map<String, dynamic>> records) async {
    final db = context.read<AppDatabase>();
    for (final record in records) {
      final studentId = record['student_id'] as String?;
      final name = record['name'] as String? ?? 'Unknown';
      final enrollmentNo = record['enrollment_no'] as String? ?? '';

      final dateStr = record['date'] as String?;
      final timeStr = record['time'] as String?;
      if (dateStr == null) continue;

      final dateParts = dateStr.split('-');
      final date = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );

      DateTime createdAt = date;
      if (timeStr != null) {
        final timeParts = timeStr.split(':');
        createdAt = DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
          timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
        );
      }

      final recordId = record['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
      await db.attendanceDao.upsertAttendance(
        id: recordId,
        studentId: studentId,
        classId: widget.classId,
        studentName: name,
        enrollmentNo: enrollmentNo,
        date: date,
        status: 'present',
        createdAt: createdAt,
      );
    }
  }

  String get _qrData {
    final url = _cloud.baseUrl;
    return 'ONLINE|$url|${widget.classId}|${widget.className}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Attendance'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Server URL input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Server URL',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _urlController,
                            decoration: const InputDecoration(
                              hintText: 'https://your-app.onrender.com',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onSubmitted: (_) => _checkConnection(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _checkConnection,
                          child: const Text('Connect'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.check_circle : Icons.error_outline,
                          size: 16,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isConnected ? 'Connected' : 'Not connected',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Class info
            Text(
              widget.className,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Attendance count
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      '$_onlineCount students marked',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // QR Code
            if (_isConnected)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _qrData,
                  version: QrVersions.auto,
                  size: 250,
                  backgroundColor: Colors.white,
                ),
              )
            else
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 48, color: Colors.grey.shade500),
                    const SizedBox(height: 8),
                    Text(
                      'Connect to server\nto show QR',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            Text(
              'Students: Open Student App → Join Class (Online)\n→ Point camera at this QR code',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
