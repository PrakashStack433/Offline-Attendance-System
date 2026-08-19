import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      return false;
    }

    final result = await Permission.camera.request();
    return result.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    final result = await Permission.manageExternalStorage.request();
    return result.isGranted;
  }

  static Future<void> showPermissionDeniedDialog(BuildContext context, {String? title, String? message}) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning, size: 48, color: Colors.orange),
        title: Text(title ?? 'Permission Required'),
        content: Text(
          message ?? 'Permission is needed to save files. Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
