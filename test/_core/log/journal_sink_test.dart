import 'package:auth_app/_core/database/database.dart' hide isNull;
import 'package:auth_app/_core/log/journal_sink.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:flutter_test/flutter_test.dart';

/// The journal's five promises, none of which was held by a test before.
///
/// It is the only durable record this app keeps of its own behaviour: the dev menu reads it, the
/// support mail is made of it, and "what led to this" is answered from it or from nowhere. Every
/// promise below exists because it was once broken — the boot was missing, the last line before a
/// crash was missing, the tail of the session was missing.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Database database;
  late JournalSink journal;

  setUp(() {
    database = Database.memory('journal_sink_test');
    // A day, so nothing lands on a timer: every write below is the one the test asked for.
    journal = JournalSink(database, flushInterval: const Duration(days: 1));
  });

  tearDown(() async {
    await journal.dispose();
    await database.close();
  });

  Future<List<LogTblData>> rows() => database.select(database.logTbl).get();

  /// A [LogEvent] with the fields a test cares about and defaults for the rest. `timestamp` must
  /// be UTC — the event asserts it, and that is the detail every hand-rolled builder gets wrong.
  LogEvent logEvent({
    LogLevel level = LogLevel.error,
    String body = 'Auth | signIn | failed',
    Map<String, Object?> meta = const <String, Object?>{},
    Object? error,
    String runId = 'run-under-test',
    int verbosity = 0,
  }) => LogEvent(
    level: level,
    body: body,
    timestamp: DateTime.utc(2026, 9, 4, 12),
    runId: runId,
    meta: meta,
    error: error,
    verbosity: verbosity,
  );

  test('a batch waits for the flush, and the flush waits for the disk', () async {
    journal.handle(logEvent(level: .info, body: 'Boot | ready | shown'));
    expect(await rows(), isEmpty, reason: 'batched — a burst of lines is one transaction');

    await journal.flush();
    expect((await rows()).single.message, 'Boot | ready | shown');
  });

  test('a failure is written through, without waiting for the batch', () async {
    journal.handle(logEvent(body: 'Auth | signOut | failed', error: StateError('disk')));
    // No flush: `handle` starts one itself for `error` and up, because the line before a native
    // crash is the one being looked for and five seconds is too long to hold it.
    await pumpEventQueue();

    final row = (await rows()).single;
    expect(row.message, 'Auth | signOut | failed');
    expect(row.level, LogLevel.error.severityNumber);
    expect(row.meta, contains('exception.type'));
  });

  test('drain adopts the boot, and honours the floor', () async {
    final buffer = LogBuffer()
      ..add(logEvent(level: .trace, body: 'Control | lifecycle | created', verbosity: 1))
      ..add(logEvent(level: .debug, body: 'Boot | step | done'))
      ..add(logEvent(level: .info, body: 'Environment | load | ready'));

    journal
      ..drain(buffer.events)
      ..handle(logEvent(level: .info, body: 'Router | navigate | changed'));
    await journal.flush();

    final stored = (await rows()).map((row) => row.message).toList();
    expect(stored, contains('Boot | step | done'), reason: 'the boot is what drain exists for');
    expect(stored, contains('Environment | load | ready'));
    expect(
      stored,
      isNot(contains('Control | lifecycle | created')),
      reason: 'trace is below the floor — the ring keeps it, the journal never does',
    );
  });

  test('the run id and the attributes are columns, not prose in the message', () async {
    journal.handle(
      logEvent(
        level: .warn,
        body: 'Rpc | call | failed',
        runId: 'run-7',
        meta: <String, Object?>{'rpc.path': '/auth.v1/SignIn'},
      ),
    );
    await journal.flush();

    final row = (await rows()).single;
    expect(row.message, 'Rpc | call | failed', reason: 'the body stays the grouping key');
    expect(row.runId, 'run-7');
    expect(row.meta, contains('rpc.path'));
  });

  test('an attribute JSON cannot express is stringified, and never throws', () async {
    // A log line must never be the thing that throws. The encoder renders whatever it is handed
    // (`toEncodable`), so a value that is not JSON keeps its `toString()` — which is what a
    // reader wanted anyway — and a value whose `toString()` itself throws costs the meta cell
    // and nothing else.
    journal
      ..handle(logEvent(level: .info, body: 'Settings | save | stored', meta: <String, Object?>{'app.kind': #symbol}))
      ..handle(
        logEvent(level: .info, body: 'Settings | skip | stored', meta: <String, Object?>{'app.bad': _Unsayable()}),
      );
    await journal.flush();

    final stored = <String, String?>{for (final row in await rows()) row.message: row.meta};
    expect(stored['Settings | save | stored'], contains('app.kind'));
    expect(stored, contains('Settings | skip | stored'), reason: 'the row survives its own attribute');
    expect(stored['Settings | skip | stored'], isNull);
  });

  test('dispose writes the tail before the database can be closed', () async {
    journal.handle(logEvent(level: .info, body: 'App | lifecycle | changed'));
    await journal.dispose();

    expect((await rows()).single.message, 'App | lifecycle | changed');
  });
}

/// A value whose rendering throws — the one thing `toEncodable` cannot rescue.
final class _Unsayable {
  @override
  String toString() => throw StateError('not today');
}
