import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../shared/widgets/empty_state.dart';

class ClassDetailPage extends StatelessWidget {
  final String classId;

  const ClassDetailPage({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return FutureBuilder<ClassesData?>(
      future: db.classDao.getClassById(classId),
      builder: (context, snapshot) {
        final cls = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(cls?.name ?? 'Class'),
            centerTitle: true,
            actions: [
              if (cls != null)
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Class',
                  onPressed: () => context.push('/class/new?edit=$classId'),
                ),
            ],
          ),
          body: cls == null
              ? const Center(child: Text('Class not found'))
              : _ClassDetailBody(classId: classId, className: cls.name),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/class/$classId/student/new'),
            child: const Icon(Icons.person_add),
          ),
        );
      },
    );
  }
}

class _ClassDetailBody extends StatelessWidget {
  final String classId;
  final String className;

  const _ClassDetailBody({required this.classId, required this.className});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                className,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              StreamBuilder<List<Student>>(
                stream: db.studentDao.watchStudentsByClass(classId),
                builder: (context, snap) {
                  final count = snap.data?.length ?? 0;
                  return Text('$count student${count == 1 ? '' : 's'}');
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => context.push('/class/$classId/attendance'),
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('Offline'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => context.push(
                      '/class/$classId/start-online?className=${Uri.encodeComponent(className)}',
                    ),
                    icon: const Icon(Icons.wifi, size: 18),
                    label: const Text('Online'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Students',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => context.push('/class/$classId/history'),
                icon: const Icon(Icons.history, size: 18),
                label: const Text('History'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Student>>(
            stream: db.studentDao.watchStudentsByClass(classId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final students = snapshot.data ?? [];

              if (students.isEmpty) {
                return const EmptyState(
                  icon: Icons.person_add_outlined,
                  title: 'No Students',
                  subtitle: 'Tap + to add students',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(student.rollNumber),
                      ),
                      title: Text(student.name),
                      subtitle: Text('Roll: ${student.rollNumber}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.qr_code, size: 20),
                            tooltip: 'Show QR',
                            onPressed: () => _showQR(context, student),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            tooltip: 'Edit',
                            onPressed: () => context.push(
                              '/class/$classId/student/${student.id}/edit',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showQR(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(student.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Roll: ${student.rollNumber}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${Uri.encodeComponent(student.qrCodeData)}',
                width: 200,
                height: 200,
                errorBuilder: (_, __, ___) => const Icon(Icons.qr_code, size: 200),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Show this QR to student'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
