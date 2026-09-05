import 'package:auth_app/_core/database/database.dart';
import 'package:auth_app/_core/log/journal_sink.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_app/developer/widget/logs_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_dependencies.dart';

/// What the dev journal actually RENDERS.
///
/// Three things about this screen were asserted nowhere, and each is the reason
/// someone opens it: a `trace` row is there at all (it lives only in the ring
/// buffer — no sink stores one), its tier is legible at a glance (`v1`…`v6` as
/// numbered icons, not six identical dots), and a relaunch is visibly a
/// relaunch (the run divider, which is how you tell "before the crash" from
/// "after it").
void main() {
  late Database db;
  late TestDependencies dependencies;

  setUp(() {
    db = Database.memory('logs_dialog_test');
    dependencies = TestDependencies()
      ..database = db
      ..journal = JournalSink(db, flushInterval: const Duration(days: 1));
    addTearDown(dependencies.journal.dispose);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Opens the dialog over a real database, with [rows] already stored.
  Future<void> open(WidgetTester tester, {List<LogEvent> rows = const <LogEvent>[]}) async {
    // Drift's lazy open awaits an isolate round-trip that never completes inside the fake-async
    // zone: one real query outside it opens the executor the dialog reads.
    await tester.runAsync(() async {
      await db.customSelect('SELECT 1').get();
      for (final row in rows) {
        dependencies.journal.handle(row);
      }
      await dependencies.journal.flush();
    });
    await tester.pumpApp(const LogsDialog(), dependencies: dependencies);
    await settle(tester);
  }

  LogEvent event({
    LogLevel level = LogLevel.info,
    String body = 'Auth | signIn | ok',
    String runId = 'run-1',
    int verbosity = 0,
    DateTime? at,
  }) => LogEvent(
    level: level,
    body: body,
    timestamp: at ?? DateTime.utc(2026, 9, 3, 12),
    runId: runId,
    verbosity: verbosity,
  );

  testWidgets('a live trace row is shown with its numbered tier', (tester) async {
    // Not stored, ever: `trace` has no sink, and the ring buffer is its only home.
    log.buffer.add(event(level: .trace, body: 'Control | lifecycle | created', verbosity: 1));
    addTearDown(log.buffer.clear);

    await open(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'trace'));
    await settle(tester);

    expect(find.text('Control | lifecycle | created'), findsOneWidget);
    expect(find.byIcon(Icons.looks_one), findsOneWidget, reason: 'v1 reads as its tier, not as a dot');
  });

  testWidgets('a stored error row carries the error icon', (tester) async {
    await open(
      tester,
      rows: <LogEvent>[event(level: .error, body: 'Auth | signIn | failed')],
    );

    expect(find.text('Auth | signIn | failed'), findsOneWidget);
    expect(find.byIcon(Icons.error), findsOneWidget);
  });

  testWidgets('two runs are separated by a divider naming the older one', (tester) async {
    await open(
      tester,
      rows: <LogEvent>[
        event(runId: 'run-old', body: 'Boot | step | done', at: DateTime.utc(2026, 9, 3, 11)),
        event(runId: 'run-new', body: 'Boot | ready | shown', at: DateTime.utc(2026, 9, 3, 12)),
      ],
    );

    expect(find.textContaining('run run-old'), findsOneWidget, reason: 'the divider names the run below it');
    expect(find.textContaining('run run-new'), findsNothing, reason: 'the newest run needs no divider above it');
  });
}
