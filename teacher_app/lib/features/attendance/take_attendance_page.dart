import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:async';
import '../../core/database/app_database.dart';
import '../../core/services/permission_service.dart';
import '../../core/utils/id_generator.dart';

class TakeAttendancePage extends StatefulWidget {
  final String classId;

  const TakeAttendancePage({super.key, required this.classId});

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  bool _scannerStopped = false;
  String _status = 'Point camera at student QR code';
  int _markedCount = 0;
  List<String> _markedEnrollments = [];

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
    _checkCameraPermission();
    _loadMarkedCount();
  }

  Future<void> _checkCameraPermission() async {
    final hasPermission = await PermissionService.requestCameraPermission();
    if (!hasPermission && mounted) {
      PermissionService.showPermissionDeniedDialog(context);
    }
  }

  Future<void> _loadMarkedCount() async {
    final db = context.read<AppDatabase>();
    final today = DateTime.now();
    final records = await db.attendanceDao.getAttendanceByClassAndDate(
      widget.classId,
      today,
    );
    if (mounted) {
      setState(() {
        _markedCount = records.length;
        _markedEnrollments = records.map((r) => r.enrollmentNo).toList();
      });
    }
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  Map<String, String>? _parseOfflineQr(String qrData) {
    final parts = qrData.split('|');
    if (parts.length < 4 || parts[0] != 'OFFLINE') return null;
    final name = parts[1].trim();
    final enrollmentNo = parts[2].trim();
    if (name.isEmpty || enrollmentNo.isEmpty) return null;
    return {'name': name, 'enrollmentNo': enrollmentNo};
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Attendance'),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: StreamBuilder<List<Student>>(
                stream: db.studentDao.watchStudentsByClass(widget.classId),
                builder: (context, snap) {
                  final total = snap.data?.length ?? 0;
                  return Text(
                    '$_markedCount / $total',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: _isProcessing
                ? Colors.orange.shade100
                : Colors.green.shade100,
            child: Text(
              _status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isProcessing ? Colors.orange.shade800 : Colors.green.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _scannerStopped
                ? Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.qr_code_scanner, color: Colors.white54, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            _status,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _resumeScanning,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Scan Next Student'),
                          ),
                        ],
                      ),
                    ),
                  )
                : MobileScanner(
                    controller: _scannerController!,
                    onDetect: _onDetect,
                  ),
          ),
          Expanded(
            flex: 2,
            child: _MarkedList(
              classId: widget.classId,
              markedEnrollments: _markedEnrollments,
            ),
          ),
        ],
      ),
    );
  }

  void _resumeScanning() {
    setState(() {
      _scannerStopped = false;
      _status = 'Point camera at student QR code';
    });
    _scannerController?.start();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.first;
    final qrData = barcode.rawValue;
    if (qrData == null || qrData.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _status = 'Processing...';
    });

    try {
      final parsed = _parseOfflineQr(qrData);

      if (parsed == null) {
        setState(() {
          _status = 'Unknown QR code. Try again.';
        });
        _showFeedback(false, 'Unknown QR');
        return;
      }

      final name = parsed['name']!;
      final enrollmentNo = parsed['enrollmentNo']!;

      if (_markedEnrollments.contains(enrollmentNo)) {
        setState(() {
          _status = '$name already marked today.';
        });
        _showFeedback(false, 'Already marked');
        return;
      }

      final db = context.read<AppDatabase>();
      final today = DateTime.now();
      final alreadyMarked = await db.attendanceDao.hasAlreadyMarked(
        enrollmentNo,
        widget.classId,
        today,
      );

      if (alreadyMarked) {
        setState(() {
          _status = '$name already marked today.';
        });
        _showFeedback(false, 'Already marked');
        return;
      }

      final id = generateId();
      await db.attendanceDao.markAttendance(
        AttendanceCompanion(
          id: drift.Value(id),
          classId: drift.Value(widget.classId),
          studentName: drift.Value(name),
          enrollmentNo: drift.Value(enrollmentNo),
          date: drift.Value(today),
          status: const drift.Value('present'),
          createdAt: drift.Value(today),
        ),
      );

      setState(() {
        _markedCount++;
        _markedEnrollments.add(enrollmentNo);
        _status = '✓ $name marked present';
      });
      _showFeedback(true, name);

      _scannerController?.stop();
      setState(() => _scannerStopped = true);
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showFeedback(bool success, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '✓ $name marked present' : name),
        backgroundColor: success ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _MarkedList extends StatelessWidget {
  final String classId;
  final List<String> markedEnrollments;

  const _MarkedList({
    required this.classId,
    required this.markedEnrollments,
  });

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Marked Today (${markedEnrollments.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AttendanceData>>(
              stream: db.attendanceDao.watchAttendanceByClassAndDate(
                classId,
                DateTime.now(),
              ),
              builder: (context, snapshot) {
                final records = snapshot.data ?? [];

                if (records.isEmpty) {
                  return const Center(
                    child: Text(
                      'No attendance marked yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final r = records[index];
                    return Chip(
                      avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      label: Text('${r.enrollmentNo} - ${r.studentName}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
