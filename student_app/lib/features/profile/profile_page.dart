import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/database/student_database.dart';
import '../../core/utils/id_generator.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  bool _wasEditedToday(DateTime? updatedAt) {
    if (updatedAt == null) return false;
    final now = DateTime.now();
    return updatedAt.year == now.year &&
        updatedAt.month == now.month &&
        updatedAt.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<StudentDatabase>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: StreamBuilder<StudentProfileData?>(
        stream: db.watchProfile(),
        builder: (context, snapshot) {
          final profile = snapshot.data;

          if (profile == null) {
            return const _ProfileForm(isNew: true);
          }

          final editedToday = _wasEditedToday(profile.updatedAt);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(label: 'Name', value: profile.name),
                        const SizedBox(height: 12),
                        _InfoRow(
                            label: 'Enrollment No',
                            value: profile.enrollmentNo),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Class', value: profile.className),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Section', value: profile.section),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: editedToday
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _ProfileForm(
                                  isNew: false,
                                  existingProfile: profile,
                                ),
                              ),
                            ),
                    icon: Icon(
                      Icons.edit,
                      color: editedToday ? Colors.grey : null,
                    ),
                    label: Text(
                      editedToday ? 'Can edit once a day' : 'Edit Profile',
                      style: TextStyle(
                        color: editedToday ? Colors.grey : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

class _ProfileForm extends StatefulWidget {
  final bool isNew;
  final StudentProfileData? existingProfile;

  const _ProfileForm({required this.isNew, this.existingProfile});

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _enrollmentController = TextEditingController();
  final _classController = TextEditingController();
  final _sectionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _nameController.text = widget.existingProfile!.name;
      _enrollmentController.text = widget.existingProfile!.enrollmentNo;
      _classController.text = widget.existingProfile!.className;
      _sectionController.text = widget.existingProfile!.section;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _enrollmentController.dispose();
    _classController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'Enter Your Details' : 'Edit Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isNew)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Welcome! Enter your details to get started.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'e.g. John Doe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _enrollmentController,
                decoration: const InputDecoration(
                  labelText: 'Enrollment / Roll Number',
                  hintText: 'e.g. 001',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Enter enrollment number'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _classController,
                decoration: const InputDecoration(
                  labelText: 'Class',
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
                label: Text(widget.isNew ? 'Get Started' : 'Update'),
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

    try {
      final db = context.read<StudentDatabase>();
      final now = DateTime.now();

      if (widget.isNew) {
        final id = generateId();
        await db.insertProfile(
          StudentProfileCompanion(
            id: drift.Value(id),
            name: drift.Value(_nameController.text.trim()),
            enrollmentNo: drift.Value(_enrollmentController.text.trim()),
            className: drift.Value(_classController.text.trim()),
            section: drift.Value(_sectionController.text.trim()),
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
          ),
        );
      } else {
        await db.updateProfile(
          StudentProfileCompanion(
            id: drift.Value(widget.existingProfile!.id),
            name: drift.Value(_nameController.text.trim()),
            enrollmentNo: drift.Value(_enrollmentController.text.trim()),
            className: drift.Value(_classController.text.trim()),
            section: drift.Value(_sectionController.text.trim()),
            updatedAt: drift.Value(now),
          ),
        );
      }

      if (mounted && !widget.isNew) Navigator.pop(context);
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
