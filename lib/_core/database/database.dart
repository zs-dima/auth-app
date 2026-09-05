// ignore_for_file: prefer_foreach

import 'package:auth_app/_core/database/platform/database.dart';
import 'package:auth_app/_core/database/queries.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart' show WidgetsBindingObserver, WidgetsBinding, AppLifecycleState;
import 'package:meta/meta.dart';

export 'package:drift/drift.dart' hide DatabaseOpener;
export 'package:drift/isolate.dart';

part 'database.g.dart';

/// Key-value storage interface for SQLite database
abstract interface class IKeyValueStorage {
  /// Refresh key-value storage from database
  Future<void> refresh();

  /// Get value by key
  T? getKey<T extends Object>(String key);

  /// Set value by key
  void setKey(String key, Object? value);

  /// Remove value by key
  void removeKey(String key);

  /// Get all values
  Map<String, Object?> getAll([Set<String>? keys]);

  /// Set all values
  void setAll(Map<String, Object?> data);

  /// Remove all values
  void removeAll([Set<String>? keys]);
}

@DriftDatabase(
  // characteristic.drift (generic JSON-doc store) and settings.drift were removed 2026-09-02:
  // dead since birth, zero readers/writers (storage doctrine: a table appears with its first
  // consumer). Existing installs drop them in the v2 rung below.
  include: <String>{
    'ddl/kv.drift',
    'ddl/log.drift',
  },
  tables: <Type>[],
  daos: <Type>[],
  queries: $queries,
)
class Database extends _$Database
    with _DatabaseKeyValueMixin, WidgetsBindingObserver, _CloseOnDetachedAppLifecycleState
    implements GeneratedDatabase, DatabaseConnectionUser, QueryExecutorUser, IKeyValueStorage {
  /// Creates a database that will store its result in the [path], creating it
  /// if it doesn't exist.
  ///
  /// [path] - file path to database for native platforms and database name for web platform.
  ///
  /// If [logStatements] is true (defaults to `false`), generated sql statements
  /// will be printed before executing. This can be useful for debugging.
  /// The optional [setup] function can be used to perform a setup just after
  /// the database is opened, before moor is fully ready. This can be used to
  /// add custom user-defined sql functions or to provide encryption keys in
  /// SQLCipher implementations.
  Database.lazy(
    String databaseName, {
    String? path,
    bool logStatements = false,
    bool dropDatabase = false,
  }) : super(
         LazyDatabase(
           () => $createQueryExecutor(
             databaseName,
             path: path,
             logStatements: logStatements,
             dropDatabase: dropDatabase,
           ),
         ),
       ) {
    _init();
  }

  /// Creates a database from an existing [executor].
  Database.connect(super.connection);

  /// Creates an in-memory database won't persist its changes on disk.
  ///
  /// If [logStatements] is true (defaults to `false`), generated sql statements
  /// will be printed before executing. This can be useful for debugging.
  /// The optional [setup] function can be used to perform a setup just after
  /// the database is opened, before moor is fully ready. This can be used to
  /// add custom user-defined sql functions or to provide encryption keys in
  /// SQLCipher implementations.
  Database.memory(
    String databaseName, {
    bool logStatements = false,
  }) : super(
         LazyDatabase(
           () => $createQueryExecutor(
             databaseName,
             logStatements: logStatements,
             memoryDatabase: true,
           ),
         ),
       );
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => const DatabaseMigrationStrategy();
}

/// Handles database migrations by delegating work to [OnCreate] and [OnUpgrade]
/// methods.
@immutable
class DatabaseMigrationStrategy implements MigrationStrategy {
  /// Construct a migration strategy from the provided [onCreate] and
  /// [onUpgrade] methods.
  const DatabaseMigrationStrategy();

  /// Executes when the database is opened for the first time.
  @override
  OnCreate get onCreate => (m) async {
    await m.createAll();
  };

  /// Executes when the database has been opened previously, but the last access
  /// happened at a different [GeneratedDatabase.schemaVersion].
  ///
  /// A REAL versioned ladder — the template body was `createAll()` with no version dispatch,
  /// which silently does nothing for an existing install on the first schema bump. The
  /// `default: throw` is the point: shipping a schema version without writing its rung must
  /// fail loudly in the first debug run, not corrupt quietly in the field.
  @override
  OnUpgrade get onUpgrade => (m, from, to) async {
    if (from > to) {
      throw StateError('Database downgrade from v$from to v$to is not supported');
    }
    for (var target = from + 1; target <= to; target++) {
      switch (target) {
        case 2:
          // 2026-09-02: drop the dead-since-birth tables (characteristic doc-store, settings
          // shadow table, log-prefix search index). DROP TABLE takes their indexes and
          // triggers with them; IF EXISTS keeps the rung idempotent.
          await m.database.customStatement('DROP TABLE IF EXISTS characteristic_tbl;');
          await m.database.customStatement('DROP TABLE IF EXISTS settings_tbl;');
          await m.database.customStatement('DROP TABLE IF EXISTS log_prefix_tbl;');

        case 3:
          // 2026-09-03: the journal stores an event, not a sentence — its
          // attributes and the launch that produced it become columns.
          //
          // `level` changed MEANING in the same rung: 0-6 (`package:l`, descending, with `error`
          // and `v1` both 1) became the OpenTelemetry severity number, 1-21 ascending. No data
          // migration goes with it, and that is deliberate rather than forgotten: the row writer
          // was commented out in every commit that ever had it (`git log -S LogTblCompanion.insert`
          // finds one, already commented), so no released build wrote a row on the old scale.
          // A remap would be guesswork over an ambiguous scale, applied to nothing.
          await m.database.customStatement('ALTER TABLE log_tbl ADD COLUMN meta TEXT;');
          await m.database.customStatement('ALTER TABLE log_tbl ADD COLUMN run_id TEXT;');

        default:
          await _missingMigration(target);
      }
    }
    // AFTER the ladder, so the row means what it says. Logged before it, this line claimed
    // "applied" over a rung that then threw — and over a downgrade that is refused outright.
    // The first journal row of the launch after an upgrade: without it the only trace of a
    // migration was `AppMigrator`'s version line, which says what the APP moved between, not
    // what the schema did.
    log.i('Database | migrate | applied', meta: <String, Object?>{'db.from': from, 'db.to': to});
  };

  /// Executes after the database is ready to be used (ie. it has been opened
  /// and all migrations ran), but before any other queries will be sent. This
  /// makes it a suitable place to populate data after the database has been
  /// created or set sqlite `PRAGMAS` that you need.
  @override
  OnBeforeOpen get beforeOpen =>
      (details) => Future.value();

  static Future<void> _missingMigration(int target) async =>
      throw StateError('No migration to schema v$target — write the rung before bumping schemaVersion');
}

mixin _DatabaseKeyValueMixin on _$Database implements IKeyValueStorage {
  bool _$isInitialized = false;
  final _$store = <String, Object>{};

  static KvTblCompanion? _kvCompanionFromKeyValue(String key, Object? value) => switch (value) {
    final String vstring => .insert(k: key, vstring: Value(vstring)),
    final int vint => .insert(k: key, vint: Value(vint)),
    final double vdouble => .insert(k: key, vdouble: Value(vdouble)),
    final bool vbool => .insert(k: key, vbool: Value(vbool ? 1 : 0)),
    _ => null,
  };

  @override
  Future<void> refresh() => select(kvTbl).get().then<void>((values) {
    _$isInitialized = true;
    _$store
      ..clear()
      ..addAll(<String, Object>{
        for (final kv in values) kv.k: kv.vstring ?? kv.vint ?? kv.vdouble ?? (kv.vbool == 1),
      });
  });

  @override
  T? getKey<T extends Object>(String key) {
    assert(_$isInitialized, 'Database is not initialized');
    final v = _$store[key];
    assert(v == null || v is T, 'Value of "$key" is not of type $T');
    return v is T ? v : null;
  }

  @override
  void setKey(String key, Object? value) {
    if (value == null) return removeKey(key);
    assert(_$isInitialized, 'Database is not initialized');
    _$store[key] = value;
    final entity = _kvCompanionFromKeyValue(key, value);
    assert(entity != null, 'Value type of "$key" is not supported');
    if (entity == null) return;
    into(kvTbl).insertOnConflictUpdate(entity).ignore();
  }

  @override
  void removeKey(String key) {
    assert(_$isInitialized, 'Database is not initialized');
    _$store.remove(key);
    (delete(kvTbl)..where((tbl) => tbl.k.equals(key))).go().ignore();
  }

  @override
  Map<String, Object> getAll([Set<String>? keys]) {
    assert(_$isInitialized, 'Database is not initialized');
    return keys == null
        ? Map<String, Object>.of(_$store)
        : <String, Object>{
            for (final e in _$store.entries)
              if (keys.contains(e.key)) e.key: e.value,
          };
  }

  @override
  void setAll(Map<String, Object?> data) {
    assert(_$isInitialized, 'Database is not initialized');
    if (data.isEmpty) return;
    final entries = <(String, Object?, KvTblCompanion?)>[
      for (final e in data.entries) (e.key, e.value, _kvCompanionFromKeyValue(e.key, e.value)),
    ];
    final toDelete = entries.where((e) => e.$3 == null).map<String>((e) => e.$1).toSet();
    final toInsert = entries.expand<(String, Object, KvTblCompanion)>((e) sync* {
      final value = e.$2;
      final companion = e.$3;
      if (companion == null || value == null) return;
      yield (e.$1, value, companion);
    }).toList();
    for (final key in toDelete) {
      _$store.remove(key);
    }
    _$store.addAll(<String, Object>{for (final e in toInsert) e.$1: e.$2});
    batch(
      (b) => b
        ..deleteWhere(kvTbl, (tbl) => tbl.k.isIn(toDelete))
        ..insertAllOnConflictUpdate(kvTbl, toInsert.map((e) => e.$3).toList(growable: false)),
    ).ignore();
  }

  @override
  void removeAll([Set<String>? keys]) {
    assert(_$isInitialized, 'Database is not initialized');
    if (keys == null) {
      _$store.clear();
      delete(kvTbl).go().ignore();
    } else if (keys.isNotEmpty) {
      for (final key in keys) {
        _$store.remove(key);
      }
      (delete(kvTbl)..where((tbl) => tbl.k.isIn(keys))).go().ignore();
    }
  }
}

mixin _CloseOnDetachedAppLifecycleState on WidgetsBindingObserver, GeneratedDatabase {
  void _init() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == .detached) close();
    super.didChangeAppLifecycleState(state);
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
