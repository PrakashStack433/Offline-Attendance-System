// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_dao.dart';

// ignore_for_file: type=lint
mixin _$StudentDaoMixin on DatabaseAccessor<AppDatabase> {
  $ClassesTable get classes => attachedDatabase.classes;
  $StudentsTable get students => attachedDatabase.students;
  StudentDaoManager get managers => StudentDaoManager(this);
}

class StudentDaoManager {
  final _$StudentDaoMixin _db;
  StudentDaoManager(this._db);
  $$ClassesTableTableManager get classes =>
      $$ClassesTableTableManager(_db.attachedDatabase, _db.classes);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db.attachedDatabase, _db.students);
}
