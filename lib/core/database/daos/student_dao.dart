import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/students.dart';

part 'student_dao.g.dart';

@DriftAccessor(tables: [Students])
class StudentDao extends DatabaseAccessor<AppDatabase> with _$StudentDaoMixin {
  StudentDao(super.db);

  Future<List<Student>> getStudentsByClass(String classId) {
    return (select(students)
          ..where((t) => t.classId.equals(classId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.rollNumber)]))
        .get();
  }

  Stream<List<Student>> watchStudentsByClass(String classId) {
    return (select(students)
          ..where((t) => t.classId.equals(classId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.rollNumber)]))
        .watch();
  }

  Future<Student?> getStudentById(String id) {
    return (select(students)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Student?> getStudentByQrData(String qrData) {
    return (select(students)
          ..where((t) => t.qrCodeData.equals(qrData) & t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<void> insertStudent(StudentsCompanion entry) {
    return into(students).insert(entry);
  }

  Future<void> updateStudent(StudentsCompanion entry) {
    return (update(students)..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  Future<void> softDeleteStudent(String id) {
    final now = DateTime.now();
    return (update(students)..where((t) => t.id.equals(id))).write(
      StudentsCompanion(
        isDeleted: const Value(true),
        synced: const Value(false),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> getStudentCount(String classId) async {
    final query = selectOnly(students)
      ..addColumns([students.id.count()])
      ..where(students.classId.equals(classId) & students.isDeleted.equals(false));
    final result = await query.getSingle();
    return result.read(students.id.count()) ?? 0;
  }
}
