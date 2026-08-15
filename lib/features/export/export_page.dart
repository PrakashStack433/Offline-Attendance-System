import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/database/app_database.dart';
import 'export_service.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ClassesData>>(
        stream: db.classDao.watchAllClasses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final classes = snapshot.data ?? [];

          if (classes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No classes to export', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final cls = classes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    child: Text(cls.name[0].toUpperCase()),
                  ),
                  title: Text(cls.name),
                  subtitle: Text('Section: ${cls.section}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Export attendance (last 30 days)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _ExportButton(
                                  label: 'CSV',
                                  icon: Icons.table_chart,
                                  color: Colors.green,
                                  onPressed: () => _export(
                                    context,
                                    cls,
                                    ExportFormat.csv,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ExportButton(
                                  label: 'PDF',
                                  icon: Icons.picture_as_pdf,
                                  color: Colors.red,
                                  onPressed: () => _export(
                                    context,
                                    cls,
                                    ExportFormat.pdf,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ExportButton(
                                  label: 'TXT',
                                  icon: Icons.text_snippet,
                                  color: Colors.blue,
                                  onPressed: () => _export(
                                    context,
                                    cls,
                                    ExportFormat.txt,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _export(BuildContext context, ClassesData cls, ExportFormat format) async {
    final db = context.read<AppDatabase>();
    final service = ExportService(db);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating export...')),
    );

    try {
      switch (format) {
        case ExportFormat.csv:
          await service.exportCsv(cls.id, cls.name);
        case ExportFormat.pdf:
          await service.exportPdf(cls.id, cls.name);
        case ExportFormat.txt:
          await service.exportTxt(cls.id, cls.name);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}

enum ExportFormat { csv, pdf, txt }

class _ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ExportButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 18),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
