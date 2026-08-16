import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/database/student_database.dart';
import '../../core/services/server_service.dart';

class JoinClassPage extends StatefulWidget {
  const JoinClassPage({super.key});

  @override
  State<JoinClassPage> createState() => _JoinClassPageState();
}

class _JoinClassPageState extends State<JoinClassPage> {
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  String _status = 'Point camera at teacher QR code';

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Class (Online)'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Text(
              _status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: MobileScanner(
              controller: _scannerController!,
              onDetect: _onDetect,
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
      final parts = qrData.split('|');
      if (parts.length < 4 || parts[0] != 'ONLINE') {
        setState(() {
          _status = 'Invalid QR code. Expected teacher attendance QR.';
          _isProcessing = false;
        });
        return;
      }

      final serverUrl = parts[1];
      final classId = parts[2];
      final className = parts[3];

      final db = context.read<StudentDatabase>();
      final profile = await db.getProfile();

      if (profile == null) {
        setState(() {
          _status = 'Please set up your profile first.';
          _isProcessing = false;
        });
        return;
      }

      final serverService = ServerService();
      serverService.setServerUrl(serverUrl);

      final connected = await serverService.healthCheck();
      if (!connected) {
        setState(() {
          _status = 'Cannot connect to teacher server.';
          _isProcessing = false;
        });
        return;
      }

      final marked = await serverService.markAttendance(
        classId: classId,
        className: className,
        studentId: profile.id,
        name: profile.name,
        enrollmentNo: profile.enrollmentNo,
      );

      if (marked) {
        await db.updateProfile(
          StudentProfileCompanion(
            id: drift.Value(profile.id),
            teacherServerUrl: drift.Value(serverUrl),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Attendance marked for $className'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _status = 'Failed to mark attendance. Try again.';
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isProcessing = false;
      });
    }
  }
}
