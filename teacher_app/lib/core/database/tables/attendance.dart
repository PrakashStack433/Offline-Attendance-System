import 'package:drift/drift.dart';
import 'classes.dart';
import 'students.dart';

class Attendance extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text().nullable().references(Students, #id)();
  TextColumn get classId => text().references(Classes, #id)();
  TextColumn get studentName => text().withLength(min: 1, max: 100)();
  TextColumn get enrollmentNo => text().withLength(min: 1, max: 20)();
  DateTimeColumn get date => dateTime()();
  TextColumn get status => text().withLength(min: 1, max: 20)();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
