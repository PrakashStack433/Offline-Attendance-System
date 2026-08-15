import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/database/app_database.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();

  runApp(
    Provider<AppDatabase>(
      create: (_) => database,
      dispose: (_, db) => db.close(),
      child: const AttendanceApp(),
    ),
  );
}
