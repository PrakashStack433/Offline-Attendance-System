import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/attendance.dart';

part 'attendance_dao.g.dart';

@DriftAccessor(tables: [Attendance])
class AttendanceDao extends DatabaseAccessor<AppDatabase>
    with _$AttendanceDaoMixin {
  AttendanceDao(super.db);

  Future<void> markAttendance(AttendanceCompanion entry) {
    return into(attendance).insert(entry);
  }

  Future<List<AttendanceData>> getAttendanceByClassAndDate(
      String classId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(attendance)
          ..where((t) =>
              t.classId.equals(classId) &
              t.date.isBetweenValues(startOfDay, endOfDay) &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Stream<List<AttendanceData>> watchAttendanceByClassAndDate(
      String classId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(attendance)
          ..where((t) =>
              t.classId.equals(classId) &
              t.date.isBetweenValues(startOfDay, endOfDay) &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<List<AttendanceData>> getAttendanceByStudent(String studentId) {
    return (select(attendance)
          ..where((t) => t.studentId.equals(studentId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<AttendanceData>> getAttendanceByDateRange(
      String classId, DateTime start, DateTime end) {
    return (select(attendance)
          ..where((t) =>
              t.classId.equals(classId) &
              t.date.isBetweenValues(start, end) &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<bool> hasAlreadyMarked(String studentId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final result = await (select(attendance)
          ..where((t) =>
              t.studentId.equals(studentId) &
              t.date.isBetweenValues(startOfDay, endOfDay) &
              t.isDeleted.equals(false)))
        .getSingleOrNull();
    return result != null;
  }

  Future<void> softDeleteAttendance(String id) {
    return (update(attendance)..where((t) => t.id.equals(id))).write(
      const AttendanceCompanion(
        isDeleted: Value(true),
        synced: Value(false),
      ),
    );
  }
}
