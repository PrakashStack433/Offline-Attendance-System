import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/database/app_database.dart';
import '../../core/services/permission_service.dart';
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
                          _ExportRow(
                            label: 'CSV',
                            icon: Icons.table_chart,
                            color: Colors.green,
                            onShare: () => _share(context, cls, ExportFormat.csv),
                            onDownload: () => _download(context, cls, ExportFormat.csv),
                          ),
                          const SizedBox(height: 8),
                          _ExportRow(
                            label: 'PDF',
                            icon: Icons.picture_as_pdf,
                            color: Colors.red,
                            onShare: () => _share(context, cls, ExportFormat.pdf),
                            onDownload: () => _download(context, cls, ExportFormat.pdf),
                          ),
                          const SizedBox(height: 8),
                          _ExportRow(
                            label: 'TXT',
                            icon: Icons.text_snippet,
                            color: Colors.blue,
                            onShare: () => _share(context, cls, ExportFormat.txt),
                            onDownload: () => _download(context, cls, ExportFormat.txt),
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

  Future<void> _share(BuildContext context, ClassesData cls, ExportFormat format) async {
    final db = context.read<AppDatabase>();
    final service = ExportService(db);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preparing to share...')),
    );

    try {
      switch (format) {
        case ExportFormat.csv:
          await service.shareCsv(cls.id, cls.name);
        case ExportFormat.pdf:
          await service.sharePdf(cls.id, cls.name);
        case ExportFormat.txt:
          await service.shareTxt(cls.id, cls.name);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }

  Future<void> _download(BuildContext context, ClassesData cls, ExportFormat format) async {
    final hasPermission = await PermissionService.requestStoragePermission();
    if (!hasPermission) {
      if (context.mounted) {
        await PermissionService.showPermissionDeniedDialog(
          context,
          title: 'Storage Permission Required',
          message: 'Storage permission is needed to save files to Downloads folder. Please enable it in app settings.',
        );
      }
      return;
    }

    final db = context.read<AppDatabase>();
    final service = ExportService(db);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving to Downloads folder...')),
    );

    try {
      String path;
      switch (format) {
        case ExportFormat.csv:
          path = await service.saveCsvToDevice(cls.id, cls.name);
        case ExportFormat.pdf:
          path = await service.savePdfToDevice(cls.id, cls.name);
        case ExportFormat.txt:
          path = await service.saveTxtToDevice(cls.id, cls.name);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to Downloads: $path'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }
}

enum ExportFormat { csv, pdf, txt }

class _ExportRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onShare;
  final VoidCallback onDownload;

  const _ExportRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.onShare,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        const Spacer(),
        IconButton(
          onPressed: onDownload,
          icon: Icon(Icons.download, color: color, size: 20),
          tooltip: 'Save to device',
        ),
        IconButton(
          onPressed: onShare,
          icon: Icon(Icons.share, color: color, size: 20),
          tooltip: 'Share',
        ),
      ],
    );
  }
}
