import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:async';
import '../../core/database/app_database.dart';
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
  String _status = 'Point camera at student QR code';
  int _markedCount = 0;
  List<String> _markedStudents = [];

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
    _loadMarkedCount();
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
        _markedStudents = records.map((r) => r.studentId).toList();
      });
    }
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
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
            child: MobileScanner(
              controller: _scannerController!,
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 2,
            child: _MarkedList(
              classId: widget.classId,
              markedStudentIds: _markedStudents,
            ),
          ),
        ],
      ),
    );
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
      final db = context.read<AppDatabase>();
      final student = await db.studentDao.getStudentByQrData(qrData);

      if (student == null) {
        setState(() {
          _status = 'Unknown QR code. Try again.';
        });
        _showFeedback(false, 'Unknown QR');
        return;
      }

      if (_markedStudents.contains(student.id)) {
        setState(() {
          _status = '${student.name} already marked today.';
        });
        _showFeedback(false, 'Already marked');
        return;
      }

      final today = DateTime.now();
      final alreadyMarked = await db.attendanceDao.hasAlreadyMarked(
        student.id,
        today,
      );

      if (alreadyMarked) {
        setState(() {
          _status = '${student.name} already marked today.';
        });
        _showFeedback(false, 'Already marked');
        return;
      }

      final id = generateId();
      await db.attendanceDao.markAttendance(
        AttendanceCompanion(
          id: drift.Value(id),
          studentId: drift.Value(student.id),
          classId: drift.Value(widget.classId),
          date: drift.Value(today),
          status: const drift.Value('present'),
          createdAt: drift.Value(today),
        ),
      );

      setState(() {
        _markedCount++;
        _markedStudents.add(student.id);
        _status = '✓ ${student.name} marked present';
      });
      _showFeedback(true, student.name);
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
  final List<String> markedStudentIds;

  const _MarkedList({
    required this.classId,
    required this.markedStudentIds,
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
              'Marked Today (${markedStudentIds.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: db.studentDao.watchStudentsByClass(classId),
              builder: (context, snapshot) {
                final students = snapshot.data ?? [];
                final marked = students
                    .where((s) => markedStudentIds.contains(s.id))
                    .toList();

                if (marked.isEmpty) {
                  return const Center(
                    child: Text(
                      'No attendance marked yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: marked.length,
                  itemBuilder: (context, index) {
                    final s = marked[index];
                    return Chip(
                      avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      label: Text('${s.rollNumber} - ${s.name}'),
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
