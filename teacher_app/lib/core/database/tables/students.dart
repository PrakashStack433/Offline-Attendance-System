import 'package:drift/drift.dart';
import 'classes.dart';

class Students extends Table {
  TextColumn get id => text()();
  TextColumn get classId => text().references(Classes, #id)();
  TextColumn get rollNumber => text().withLength(min: 1, max: 20)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get qrCodeData => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
