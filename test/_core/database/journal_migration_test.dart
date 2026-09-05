// Both drift and matcher define `isNull`; the matcher one is what a test means by it.
import 'package:auth_app/_core/database/database.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The schema a shipped install is actually at: v1, the version every released build wrote
/// (`git show HEAD:lib/_core/database/database.dart` — `schemaVersion => 1`). The earlier fixture
/// started from a hand-built "v2" that never shipped, so the rung every real device takes first —
/// v2's three `DROP TABLE`s — and the composite 1 → 3 path were never executed by a test.
const List<String> _kV1Schema = <String>[
  '''
CREATE TABLE log_tbl (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    time INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    level INTEGER NOT NULL,
    message TEXT NOT NULL,
    stack TEXT
) STRICT;
''',
  'CREATE INDEX log_time_idx ON log_tbl (time);',
  'CREATE INDEX log_level_idx ON log_tbl (level);',
  // The hand-rolled prefix search index nothing ever wrote to, with its FK onto log_tbl.
  '''
CREATE TABLE log_prefix_tbl (
    prefix TEXT NOT NULL,
    log_id INTEGER NOT NULL,
    word TEXT NOT NULL,
    len INTEGER NOT NULL,
    PRIMARY KEY (prefix, log_id, word),
    FOREIGN KEY (log_id) REFERENCES log_tbl (id) ON UPDATE CASCADE ON DELETE CASCADE
) STRICT;
''',
  'CREATE INDEX log_prefix_prefix_idx ON log_prefix_tbl (prefix);',
  // The generic JSON document store, with the trigger that came with it.
  '''
CREATE TABLE characteristic_tbl (
    type TEXT NOT NULL CHECK(length(type) > 0 AND length(type) <= 255),
    id INTEGER NOT NULL,
    data TEXT NOT NULL CHECK(length(data) > 2 AND json_valid(data)),
    meta_created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    meta_updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')) CHECK(meta_updated_at >= meta_created_at),
    PRIMARY KEY (type, id)
) STRICT;
''',
  '''
CREATE TRIGGER characteristic_meta_updated_at_trig AFTER UPDATE ON characteristic_tbl
    BEGIN
        UPDATE characteristic_tbl SET meta_updated_at = strftime('%s', 'now') WHERE type = NEW.type AND id = NEW.id;
    END;
''',
  // The settings shadow table.
  '''
CREATE TABLE settings_tbl (
    user_id TEXT NOT NULL PRIMARY KEY,
    json_data TEXT NOT NULL CHECK(length(json_data) > 2 AND json_valid(json_data)),
    memo TEXT,
    meta_created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    meta_updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')) CHECK(meta_updated_at >= meta_created_at)
) STRICT;
''',
];

/// Opens an in-memory database that looks like an install left at [version], so opening it runs
/// the real upgrade ladder rather than `createAll`.
Database _databaseAt(int version, {List<String> seed = const <String>[]}) => .connect(
  DatabaseConnection(
    NativeDatabase.memory(
      setup: (raw) {
        for (final statement in _kV1Schema) {
          raw.execute(statement);
        }
        if (version >= 2) {
          for (final table in const <String>['characteristic_tbl', 'settings_tbl', 'log_prefix_tbl']) {
            raw.execute('DROP TABLE IF EXISTS $table;');
          }
        }
        for (final statement in seed) {
          raw.execute(statement);
        }
        raw.execute('PRAGMA user_version = $version;');
      },
    ),
  ),
);

/// Whether [table] survived the ladder.
Future<bool> _exists(Database database, String table) async {
  final rows = await database
      .customSelect("SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?", variables: [Variable(table)])
      .get();
  return rows.isNotEmpty;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('journal schema v1 → v3 (the path a shipped install takes)', () {
    test('drops the tables nothing ever wrote to and adds the event columns', () async {
      final database = _databaseAt(
        1,
        seed: const <String>[
          "INSERT INTO log_tbl (time, level, message) VALUES (1756800000, 3, 'Boot | step | slow');",
        ],
      );
      addTearDown(database.close);

      // Any query opens the database, which is what runs the ladder.
      final rows = await database.select(database.logTbl).get();

      expect(rows, hasLength(1), reason: 'the journal survives the upgrade');
      expect(rows.single.message, equals('Boot | step | slow'));
      expect(rows.single.meta, isNull, reason: 'a row written before the rework has no attributes');
      expect(rows.single.runId, isNull);
      for (final table in const <String>['characteristic_tbl', 'settings_tbl', 'log_prefix_tbl']) {
        final exists = await _exists(database, table);
        expect(exists, isFalse, reason: '$table is dropped by the v2 rung');
      }
    });
  });

  group('journal schema v2 → v3', () {
    test('adds the attribute and launch columns and keeps existing rows', () async {
      final database = _databaseAt(
        2,
        seed: const <String>[
          "INSERT INTO log_tbl (time, level, message) VALUES (1756800000, 13, 'Boot | step | slow');",
        ],
      );
      addTearDown(database.close);

      final rows = await database.select(database.logTbl).get();
      final row = rows.single;

      expect(row.message, equals('Boot | step | slow'), reason: 'an upgrade must not lose the journal');
      expect(row.level, equals(13));
      expect(row.meta, isNull);
      expect(row.runId, isNull);
    });

    test('the upgraded table accepts an event with attributes and a run id', () async {
      final database = _databaseAt(2);
      addTearDown(database.close);

      await database
          .into(database.logTbl)
          .insert(
            LogTblCompanion.insert(
              level: 17,
              message: 'Rpc | call | failed',
              meta: const Value<String>('{"rpc.code":"unavailable"}'),
              runId: const Value<String>('run-1'),
            ),
          );

      final rows = await (database.select(database.logTbl)..where((tbl) => tbl.level.equals(17))).get();
      final row = rows.single;
      expect(row.meta, contains('rpc.code'));
      expect(row.runId, equals('run-1'));
    });

    test('a downgrade is refused rather than silently applied', () async {
      const strategy = DatabaseMigrationStrategy();

      expect(
        () => strategy.onUpgrade(const _UnusedMigrator(), 3, 2),
        throwsA(isA<StateError>()),
      );
    });
  });
}

/// The downgrade guard rejects before touching the migrator, so it never needs
/// to be a working one.
final class _UnusedMigrator implements Migrator {
  const _UnusedMigrator();

  @override
  Object noSuchMethod(Invocation invocation) => throw StateError('the downgrade guard must reject first');
}
