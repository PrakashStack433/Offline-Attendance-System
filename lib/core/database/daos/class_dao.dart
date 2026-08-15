import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/classes.dart';

part 'class_dao.g.dart';

@DriftAccessor(tables: [Classes])
class ClassDao extends DatabaseAccessor<AppDatabase> with _$ClassDaoMixin {
  ClassDao(super.db);

  Future<List<ClassesData>> getAllClasses() {
    return (select(classes)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Stream<List<ClassesData>> watchAllClasses() {
    return (select(classes)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<ClassesData?> getClassById(String id) {
    return (select(classes)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertClass(ClassesCompanion entry) {
    return into(classes).insert(entry);
  }

  Future<void> updateClass(ClassesCompanion entry) {
    return (update(classes)..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  Future<void> softDeleteClass(String id) {
    final now = DateTime.now();
    return (update(classes)..where((t) => t.id.equals(id))).write(
      ClassesCompanion(
        isDeleted: const Value(true),
        synced: const Value(false),
        updatedAt: Value(now),
      ),
    );
  }
}
