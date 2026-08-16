import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/database/student_database.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = StudentDatabase();

  runApp(
    Provider<StudentDatabase>(
      create: (_) => database,
      dispose: (_, db) => db.close(),
      child: const StudentAttendanceApp(),
    ),
  );
}
