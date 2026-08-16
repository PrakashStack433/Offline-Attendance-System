// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_dao.dart';

// ignore_for_file: type=lint
mixin _$ClassDaoMixin on DatabaseAccessor<AppDatabase> {
  $ClassesTable get classes => attachedDatabase.classes;
  ClassDaoManager get managers => ClassDaoManager(this);
}

class ClassDaoManager {
  final _$ClassDaoMixin _db;
  ClassDaoManager(this._db);
  $$ClassesTableTableManager get classes =>
      $$ClassesTableTableManager(_db.attachedDatabase, _db.classes);
}
