import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/student_profile.dart';

part 'student_database.g.dart';

@DriftDatabase(tables: [StudentProfile])
class StudentDatabase extends _$StudentDatabase {
  StudentDatabase() : super(_openConnection());

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

  Future<StudentProfileData?> getProfile() {
    return (select(studentProfile)).getSingleOrNull();
  }

  Stream<StudentProfileData?> watchProfile() {
    return (select(studentProfile)).watchSingleOrNull();
  }

  Future<void> insertProfile(StudentProfileCompanion entry) {
    return into(studentProfile).insert(entry);
  }

  Future<void> updateProfile(StudentProfileCompanion entry) {
    return (update(studentProfile)..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  Future<bool> hasProfile() async {
    final profile = await getProfile();
    return profile != null;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'student_attendance.db'));
    return NativeDatabase.createInBackground(file);
  });
}
