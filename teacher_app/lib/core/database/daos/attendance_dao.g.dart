// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_dao.dart';

// ignore_for_file: type=lint
mixin _$AttendanceDaoMixin on DatabaseAccessor<AppDatabase> {
  $ClassesTable get classes => attachedDatabase.classes;
  $StudentsTable get students => attachedDatabase.students;
  $AttendanceTable get attendance => attachedDatabase.attendance;
  AttendanceDaoManager get managers => AttendanceDaoManager(this);
}

class AttendanceDaoManager {
  final _$AttendanceDaoMixin _db;
  AttendanceDaoManager(this._db);
  $$ClassesTableTableManager get classes =>
      $$ClassesTableTableManager(_db.attachedDatabase, _db.classes);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db.attachedDatabase, _db.students);
  $$AttendanceTableTableManager get attendance =>
      $$AttendanceTableTableManager(_db.attachedDatabase, _db.attendance);
}
