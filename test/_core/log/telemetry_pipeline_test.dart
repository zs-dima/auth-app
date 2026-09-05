import 'dart:async';

import 'package:auth_app/_core/database/database.dart';
import 'package:auth_app/_core/log/journal_sink.dart';
import 'package:auth_app/_core/log/logging_bridge.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_app/_core/message/toast_sink.dart';
import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart' as logging;

/// The app-side half of the pipeline: the sinks that know about drift, the
/// messenger and the crash reporter. The engine itself is a separate package
/// with its own gate (`telemetry`, https://pub.dev/packages/telemetry).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JournalSink', () {
    late Database database;
    late Telemetry telemetry;
    late JournalSink journal;

    setUp(() {
      database = Database.memory('telemetry_test');
      telemetry = Telemetry(runId: 'run-under-test');
      journal = JournalSink(database, flushInterval: const Duration(days: 1));
      telemetry.addSink(journal);
    });

    tearDown(() async {
      await journal.dispose();
      await database.close();
    });

    test('stores the body, the severity number, the attributes and the run id', () async {
      telemetry.w('Pairing | handshake | refused', meta: <String, Object?>{'app.pairing.attempt': 3});
      await journal.flush();

      final rows = await database.select(database.logTbl).get();
      final row = rows.single;
      expect(row.message, 'Pairing | handshake | refused');
      expect(row.level, LogLevel.warn.severityNumber);
      expect(row.runId, 'run-under-test');
      expect(row.meta, contains('app.pairing.attempt'));
    });

    test('records the exception as attributes, not inside the message', () async {
      telemetry.e('Api | call | failed', error: const FormatException('bad payload'));
      await journal.flush();

      final row = (await database.select(database.logTbl).get()).single;
      expect(row.message, 'Api | call | failed', reason: 'the body stays the grouping key');
      expect(row.meta, contains('exception.type'));
      expect(row.meta, contains('FormatException'));
    });

    test('debug lines are journaled — controller transitions among them', () async {
      // The defect the rework exists for: `d`/`v*` used to be dropped before
      // the stream, so every state transition was invisible here.
      telemetry.d(
        'Control | state | AuthenticationController',
        meta: <String, Object?>{'control.from': 'IdleState', 'control.to': 'ProcessingState'},
      );
      await journal.flush();

      final row = (await database.select(database.logTbl).get()).single;
      expect(row.level, LogLevel.debug.severityNumber);
      expect(row.meta, contains('control.to'));
    });

    test('a trace tier below the journal threshold is not stored', () async {
      telemetry.v6('Boot | step | 12/25');
      await journal.flush();

      expect(await database.select(database.logTbl).get(), isEmpty);
    });

    test('a failure is written through, without waiting for the batch', () async {
      // The five-second batch is a fine trade for a state transition and a bad one for the last
      // line before a native crash: this sink is the only record of it.
      telemetry.e('Zone | uncaught | error', error: StateError('boom'));
      // No flush() — `handle` must have started the write on its own.
      await pumpEventQueue();

      final row = (await database.select(database.logTbl).get()).single;
      expect(row.message, 'Zone | uncaught | error');
    });

    test('drain adopts the boot lines logged before the journal existed', () async {
      // The pipeline records from the first line of `main`; this sink cannot exist until the
      // database is open, ten init steps later. Everything in between used to be console-only.
      final booting = Telemetry(runId: 'run-boot')
        ..i('Boot | environment | loaded')
        ..d('Boot | database | opened')
        ..v6('Boot | frame | painted');

      final late = JournalSink(database, flushInterval: const Duration(days: 1))..drain(booting.buffer.events);
      addTearDown(late.dispose);
      await late.flush();

      final rows = await database.select(database.logTbl).get();
      expect(
        rows.map((row) => row.message),
        <String>['Boot | environment | loaded', 'Boot | database | opened'],
        reason: 'debug and up; the trace tier is below the journal floor',
      );
    });
  });

  group('UiMessengerToastSink', () {
    late UiMessenger messenger;
    late Telemetry telemetry;

    setUp(() {
      messenger = UiMessenger();
      telemetry = Telemetry(runId: 'run-toast')..toastSink = UiMessengerToastSink(messenger);
    });

    tearDown(() => messenger.dispose());

    test('an alert tone shows the localized description', () async {
      final shown = messenger.messages.first;
      telemetry('Settings | save | failed').description('Не удалось сохранить').toast(tone: .alert);

      final message = await shown;
      expect(message.tone, ToastTone.alert);
      expect(message.text, 'Не удалось сохранить');
    });

    test('the default tone is neutral information', () async {
      final shown = messenger.messages.first;
      telemetry('Settings | save | done').description('Сохранено').toast();

      final message = await shown;
      expect(message.tone, ToastTone.info);
      expect(message.text, 'Сохранено');
    });

    test('the developer body never reaches the user, but rides along as details', () async {
      final shown = messenger.messages.first;
      telemetry('Settings | save | failed').description('Не удалось сохранить').toast(tone: .alert);

      final message = await shown;
      expect(message.text, isNot(contains('|')), reason: 'no `Area | operation` in the UI');
      expect(message.details?.body, 'Settings | save | failed', reason: 'the Details action needs the event');
    });
  });

  group('UiMessenger progress', () {
    test('counts operations, so overlapping ones show one overlay', () {
      final messenger = UiMessenger();
      addTearDown(messenger.dispose);

      messenger
        ..progressStarted()
        ..progressStarted();
      expect(messenger.progress.value, 2);

      messenger.progressDone();
      expect(messenger.progress.value, 1, reason: 'the second operation is still running');

      messenger.resetProgress();
      expect(messenger.progress.value, isZero);
    });

    test('an unbalanced done cannot drive the counter negative', () {
      final messenger = UiMessenger();
      addTearDown(messenger.dispose);

      messenger.progressDone();
      expect(messenger.progress.value, isZero);
    });
  });

  group('LoggingBridge', () {
    late List<LogEvent> received;
    late StreamSubscription<LogEvent> subscription;

    setUp(() {
      final previous = logging.Logger.root.level;
      addTearDown(() => logging.Logger.root.level = previous);
      received = <LogEvent>[];
      subscription = log.events.listen(received.add);
      addTearDown(subscription.cancel);
    });

    test('forwards a package:logging record under a canonical body', () async {
      final bridge = LoggingBridge(level: logging.Level.ALL);
      addTearDown(bridge.dispose);

      // What `cupertino_http` does: its own Logger, never heard before this bridge existed.
      logging.Logger('cupertino_http').warning('session invalidated');
      await Future<void>.delayed(Duration.zero);

      // The BODY is the logger, not the sentence: the sentence is a value, and a
      // value in the body is one crash-reporter fingerprint per distinct string.
      final event = received.singleWhere((e) => e.meta['log.message'] == 'session invalidated');
      expect(event.body, 'Logging | forwarded | record', reason: 'the logger is an attribute, not a fingerprint');
      expect(event.level, LogLevel.warn);
      expect(event.meta['log.message'], 'session invalidated');
      expect(event.meta['log.logger'], 'cupertino_http');
      expect(event.meta['log.source'], 'logging');
    });

    test('a SEVERE record with no error is capped at warn', () async {
      // Otherwise a third party's idea of severe becomes this app's issue, with
      // the free text as the exception value and no stable fingerprint.
      final bridge = LoggingBridge(level: logging.Level.ALL);
      addTearDown(bridge.dispose);

      logging.Logger('cupertino_http').severe('connection reset');
      await Future<void>.delayed(Duration.zero);

      expect(received.singleWhere((e) => e.meta['log.message'] == 'connection reset').level, LogLevel.warn);
    });

    test('a SEVERE record that carries an error keeps its level', () async {
      final bridge = LoggingBridge(level: logging.Level.ALL);
      addTearDown(bridge.dispose);

      logging.Logger('cupertino_http').severe('handshake failed', StateError('boom'), StackTrace.current);
      await Future<void>.delayed(Duration.zero);

      final event = received.singleWhere((e) => e.meta['log.message'] == 'handshake failed');
      expect(event.level, LogLevel.error);
      expect(event.error, isA<StateError>());
    });
  });
}
