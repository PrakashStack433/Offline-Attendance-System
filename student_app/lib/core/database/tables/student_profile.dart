import 'package:drift/drift.dart';

class StudentProfile extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get enrollmentNo => text().withLength(min: 1, max: 20)();
  TextColumn get className => text().withLength(min: 1, max: 100)();
  TextColumn get teacherServerUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
