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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await customStatement('''
            CREATE TABLE attendance_v2 (
              id TEXT PRIMARY KEY NOT NULL,
              student_id TEXT,
              class_id TEXT NOT NULL REFERENCES classes(id),
              student_name TEXT NOT NULL DEFAULT '',
              enrollment_no TEXT NOT NULL DEFAULT '',
              date INTEGER NOT NULL,
              status TEXT NOT NULL DEFAULT 'present',
              created_at INTEGER NOT NULL,
              synced INTEGER NOT NULL DEFAULT 0,
              is_deleted INTEGER NOT NULL DEFAULT 0
            )
          ''');
          await customStatement('''
            INSERT INTO attendance_v2 (id, student_id, class_id, student_name, enrollment_no, date, status, created_at, synced, is_deleted)
            SELECT id, student_id, class_id, '', '', date, status, created_at, synced, is_deleted
            FROM attendance
          ''');
          await customStatement('DROP TABLE attendance');
          await customStatement('ALTER TABLE attendance_v2 RENAME TO attendance');
        }
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
