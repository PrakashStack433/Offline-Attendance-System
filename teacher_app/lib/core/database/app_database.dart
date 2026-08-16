import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/classes.dart';
import 'tables/students.dart';
import 'tables/attendance.dart';
import 'daos/class_dao.dart';
import 'daos/student_dao.dart';
import 'daos/attendance_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Classes, Students, Attendance],
  daos: [ClassDao, StudentDao, AttendanceDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'attendance.db'));
    return NativeDatabase.createInBackground(file);
  });
}
