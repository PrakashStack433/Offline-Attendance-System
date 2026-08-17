import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/database/app_database.dart';
import 'core/services/cloud_service.dart';
import 'core/services/permission_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PermissionService.requestCameraPermission();

  final database = AppDatabase();
  final cloudService = CloudService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>(
          create: (_) => database,
          dispose: (_, db) => db.close(),
        ),
        Provider<CloudService>(
          create: (_) => cloudService,
        ),
      ],
      child: const AttendanceApp(),
    ),
  );
}
