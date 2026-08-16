// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_database.dart';

// ignore_for_file: type=lint
class $StudentProfileTable extends StudentProfile
    with TableInfo<$StudentProfileTable, StudentProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enrollmentNoMeta = const VerificationMeta(
    'enrollmentNo',
  );
  @override
  late final GeneratedColumn<String> enrollmentNo = GeneratedColumn<String>(
    'enrollment_no',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classNameMeta = const VerificationMeta(
    'className',
  );
  @override
  late final GeneratedColumn<String> className = GeneratedColumn<String>(
    'class_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherServerUrlMeta = const VerificationMeta(
    'teacherServerUrl',
  );
  @override
  late final GeneratedColumn<String> teacherServerUrl = GeneratedColumn<String>(
    'teacher_server_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    enrollmentNo,
    className,
    teacherServerUrl,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudentProfileData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('enrollment_no')) {
      context.handle(
        _enrollmentNoMeta,
        enrollmentNo.isAcceptableOrUnknown(
          data['enrollment_no']!,
          _enrollmentNoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enrollmentNoMeta);
    }
    if (data.containsKey('class_name')) {
      context.handle(
        _classNameMeta,
        className.isAcceptableOrUnknown(data['class_name']!, _classNameMeta),
      );
    } else if (isInserting) {
      context.missing(_classNameMeta);
    }
    if (data.containsKey('teacher_server_url')) {
      context.handle(
        _teacherServerUrlMeta,
        teacherServerUrl.isAcceptableOrUnknown(
          data['teacher_server_url']!,
          _teacherServerUrlMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudentProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentProfileData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      enrollmentNo:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}enrollment_no'],
          )!,
      className:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}class_name'],
          )!,
      teacherServerUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_server_url'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $StudentProfileTable createAlias(String alias) {
    return $StudentProfileTable(attachedDatabase, alias);
  }
}

class StudentProfileData extends DataClass
    implements Insertable<StudentProfileData> {
  final String id;
  final String name;
  final String enrollmentNo;
  final String className;
  final String? teacherServerUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  const StudentProfileData({
    required this.id,
    required this.name,
    required this.enrollmentNo,
    required this.className,
    this.teacherServerUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['enrollment_no'] = Variable<String>(enrollmentNo);
    map['class_name'] = Variable<String>(className);
    if (!nullToAbsent || teacherServerUrl != null) {
      map['teacher_server_url'] = Variable<String>(teacherServerUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StudentProfileCompanion toCompanion(bool nullToAbsent) {
    return StudentProfileCompanion(
      id: Value(id),
      name: Value(name),
      enrollmentNo: Value(enrollmentNo),
      className: Value(className),
      teacherServerUrl:
          teacherServerUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(teacherServerUrl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StudentProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentProfileData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      enrollmentNo: serializer.fromJson<String>(json['enrollmentNo']),
      className: serializer.fromJson<String>(json['className']),
      teacherServerUrl: serializer.fromJson<String?>(json['teacherServerUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'enrollmentNo': serializer.toJson<String>(enrollmentNo),
      'className': serializer.toJson<String>(className),
      'teacherServerUrl': serializer.toJson<String?>(teacherServerUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StudentProfileData copyWith({
    String? id,
    String? name,
    String? enrollmentNo,
    String? className,
    Value<String?> teacherServerUrl = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => StudentProfileData(
    id: id ?? this.id,
    name: name ?? this.name,
    enrollmentNo: enrollmentNo ?? this.enrollmentNo,
    className: className ?? this.className,
    teacherServerUrl:
        teacherServerUrl.present
            ? teacherServerUrl.value
            : this.teacherServerUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StudentProfileData copyWithCompanion(StudentProfileCompanion data) {
    return StudentProfileData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      enrollmentNo:
          data.enrollmentNo.present
              ? data.enrollmentNo.value
              : this.enrollmentNo,
      className: data.className.present ? data.className.value : this.className,
      teacherServerUrl:
          data.teacherServerUrl.present
              ? data.teacherServerUrl.value
              : this.teacherServerUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentProfileData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('enrollmentNo: $enrollmentNo, ')
          ..write('className: $className, ')
          ..write('teacherServerUrl: $teacherServerUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    enrollmentNo,
    className,
    teacherServerUrl,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentProfileData &&
          other.id == this.id &&
          other.name == this.name &&
          other.enrollmentNo == this.enrollmentNo &&
          other.className == this.className &&
          other.teacherServerUrl == this.teacherServerUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StudentProfileCompanion extends UpdateCompanion<StudentProfileData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> enrollmentNo;
  final Value<String> className;
  final Value<String?> teacherServerUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StudentProfileCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.enrollmentNo = const Value.absent(),
    this.className = const Value.absent(),
    this.teacherServerUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentProfileCompanion.insert({
    required String id,
    required String name,
    required String enrollmentNo,
    required String className,
    this.teacherServerUrl = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       enrollmentNo = Value(enrollmentNo),
       className = Value(className),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<StudentProfileData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? enrollmentNo,
    Expression<String>? className,
    Expression<String>? teacherServerUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (enrollmentNo != null) 'enrollment_no': enrollmentNo,
      if (className != null) 'class_name': className,
      if (teacherServerUrl != null) 'teacher_server_url': teacherServerUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentProfileCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? enrollmentNo,
    Value<String>? className,
    Value<String?>? teacherServerUrl,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return StudentProfileCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      enrollmentNo: enrollmentNo ?? this.enrollmentNo,
      className: className ?? this.className,
      teacherServerUrl: teacherServerUrl ?? this.teacherServerUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (enrollmentNo.present) {
      map['enrollment_no'] = Variable<String>(enrollmentNo.value);
    }
    if (className.present) {
      map['class_name'] = Variable<String>(className.value);
    }
    if (teacherServerUrl.present) {
      map['teacher_server_url'] = Variable<String>(teacherServerUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentProfileCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('enrollmentNo: $enrollmentNo, ')
          ..write('className: $className, ')
          ..write('teacherServerUrl: $teacherServerUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$StudentDatabase extends GeneratedDatabase {
  _$StudentDatabase(QueryExecutor e) : super(e);
  $StudentDatabaseManager get managers => $StudentDatabaseManager(this);
  late final $StudentProfileTable studentProfile = $StudentProfileTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [studentProfile];
}

typedef $$StudentProfileTableCreateCompanionBuilder =
    StudentProfileCompanion Function({
      required String id,
      required String name,
      required String enrollmentNo,
      required String className,
      Value<String?> teacherServerUrl,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$StudentProfileTableUpdateCompanionBuilder =
    StudentProfileCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> enrollmentNo,
      Value<String> className,
      Value<String?> teacherServerUrl,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$StudentProfileTableFilterComposer
    extends Composer<_$StudentDatabase, $StudentProfileTable> {
  $$StudentProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enrollmentNo => $composableBuilder(
    column: $table.enrollmentNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get className => $composableBuilder(
    column: $table.className,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherServerUrl => $composableBuilder(
    column: $table.teacherServerUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudentProfileTableOrderingComposer
    extends Composer<_$StudentDatabase, $StudentProfileTable> {
  $$StudentProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enrollmentNo => $composableBuilder(
    column: $table.enrollmentNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get className => $composableBuilder(
    column: $table.className,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherServerUrl => $composableBuilder(
    column: $table.teacherServerUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentProfileTableAnnotationComposer
    extends Composer<_$StudentDatabase, $StudentProfileTable> {
  $$StudentProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get enrollmentNo => $composableBuilder(
    column: $table.enrollmentNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get className =>
      $composableBuilder(column: $table.className, builder: (column) => column);

  GeneratedColumn<String> get teacherServerUrl => $composableBuilder(
    column: $table.teacherServerUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StudentProfileTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $StudentProfileTable,
          StudentProfileData,
          $$StudentProfileTableFilterComposer,
          $$StudentProfileTableOrderingComposer,
          $$StudentProfileTableAnnotationComposer,
          $$StudentProfileTableCreateCompanionBuilder,
          $$StudentProfileTableUpdateCompanionBuilder,
          (
            StudentProfileData,
            BaseReferences<
              _$StudentDatabase,
              $StudentProfileTable,
              StudentProfileData
            >,
          ),
          StudentProfileData,
          PrefetchHooks Function()
        > {
  $$StudentProfileTableTableManager(
    _$StudentDatabase db,
    $StudentProfileTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$StudentProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$StudentProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$StudentProfileTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> enrollmentNo = const Value.absent(),
                Value<String> className = const Value.absent(),
                Value<String?> teacherServerUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentProfileCompanion(
                id: id,
                name: name,
                enrollmentNo: enrollmentNo,
                className: className,
                teacherServerUrl: teacherServerUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String enrollmentNo,
                required String className,
                Value<String?> teacherServerUrl = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => StudentProfileCompanion.insert(
                id: id,
                name: name,
                enrollmentNo: enrollmentNo,
                className: className,
                teacherServerUrl: teacherServerUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudentProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $StudentProfileTable,
      StudentProfileData,
      $$StudentProfileTableFilterComposer,
      $$StudentProfileTableOrderingComposer,
      $$StudentProfileTableAnnotationComposer,
      $$StudentProfileTableCreateCompanionBuilder,
      $$StudentProfileTableUpdateCompanionBuilder,
      (
        StudentProfileData,
        BaseReferences<
          _$StudentDatabase,
          $StudentProfileTable,
          StudentProfileData
        >,
      ),
      StudentProfileData,
      PrefetchHooks Function()
    >;

class $StudentDatabaseManager {
  final _$StudentDatabase _db;
  $StudentDatabaseManager(this._db);
  $$StudentProfileTableTableManager get studentProfile =>
      $$StudentProfileTableTableManager(_db, _db.studentProfile);
}
