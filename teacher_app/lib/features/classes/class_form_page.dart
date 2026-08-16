import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/database/app_database.dart';
import '../../core/utils/id_generator.dart';

class ClassFormPage extends StatefulWidget {
  final String? existingClassId;

  const ClassFormPage({super.key, this.existingClassId});

  @override
  State<ClassFormPage> createState() => _ClassFormPageState();
}

class _ClassFormPageState extends State<ClassFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sectionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingClassId != null) {
      _loadClass();
    }
  }

  Future<void> _loadClass() async {
    final db = context.read<AppDatabase>();
    final cls = await db.classDao.getClassById(widget.existingClassId!);
    if (cls != null && mounted) {
      _nameController.text = cls.name;
      _sectionController.text = cls.section;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingClassId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Class' : 'New Class'),
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
                  labelText: 'Class Name',
                  hintText: 'e.g. Mathematics',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter class name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sectionController,
                decoration: const InputDecoration(
                  labelText: 'Section',
                  hintText: 'e.g. A',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter section' : null,
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
                label: Text(isEditing ? 'Update' : 'Create'),
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
      if (widget.existingClassId != null) {
        await db.classDao.updateClass(
          ClassesCompanion(
            id: drift.Value(widget.existingClassId!),
            name: drift.Value(_nameController.text.trim()),
            section: drift.Value(_sectionController.text.trim()),
            updatedAt: drift.Value(now),
            synced: const drift.Value(false),
          ),
        );
      } else {
        final id = generateId();
        await db.classDao.insertClass(
          ClassesCompanion(
            id: drift.Value(id),
            name: drift.Value(_nameController.text.trim()),
            section: drift.Value(_sectionController.text.trim()),
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
          ),
        );
      }

      if (mounted) context.pop();
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
