import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/database/app_database.dart';
import '../../core/utils/id_generator.dart';

class StudentFormPage extends StatefulWidget {
  final String classId;
  final String? studentId;

  const StudentFormPage({
    super.key,
    required this.classId,
    this.studentId,
  });

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.studentId != null) {
      _loadStudent();
    }
  }

  Future<void> _loadStudent() async {
    final db = context.read<AppDatabase>();
    final student = await db.studentDao.getStudentById(widget.studentId!);
    if (student != null && mounted) {
      _nameController.text = student.name;
      _rollController.text = student.rollNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.studentId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Student' : 'Add Student'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  hintText: 'e.g. John Doe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter student name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rollController,
                decoration: const InputDecoration(
                  labelText: 'Roll Number',
                  hintText: 'e.g. 001',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter roll number' : null,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isLoading ? null : _save,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(isEditing ? 'Update' : 'Add Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final db = context.read<AppDatabase>();
    final now = DateTime.now();

    try {
      if (widget.studentId != null) {
        final qrData = generateQrData(
          studentId: widget.studentId!,
          classId: widget.classId,
          rollNumber: _rollController.text.trim(),
          studentName: _nameController.text.trim(),
        );
        await db.studentDao.updateStudent(
          StudentsCompanion(
            id: drift.Value(widget.studentId!),
            classId: drift.Value(widget.classId),
            name: drift.Value(_nameController.text.trim()),
            rollNumber: drift.Value(_rollController.text.trim()),
            qrCodeData: drift.Value(qrData),
            updatedAt: drift.Value(now),
            synced: const drift.Value(false),
          ),
        );
      } else {
        final id = generateId();
        final qrData = generateQrData(
          studentId: id,
          classId: widget.classId,
          rollNumber: _rollController.text.trim(),
          studentName: _nameController.text.trim(),
        );

        await db.studentDao.insertStudent(
          StudentsCompanion(
            id: drift.Value(id),
            classId: drift.Value(widget.classId),
            name: drift.Value(_nameController.text.trim()),
            rollNumber: drift.Value(_rollController.text.trim()),
            qrCodeData: drift.Value(qrData),
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
          ),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
