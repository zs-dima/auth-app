import 'dart:convert';

import 'package:auth_app/_core/environment/model/environment.dart';
import 'package:auth_app/_core/log/sentry_sink.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart'
    show
        OnErrorIntegration,
        Sentry,
        SentryEnvelope,
        SentryEnvelopeItem,
        SentryEvent,
        SentryFlutterOptions,
        SentryId,
        Transport;
// Not exported by the package; the sink imports it the same way to remove it by type.
// ignore: implementation_imports
import 'package:sentry_flutter/src/integrations/flutter_error_integration.dart';

/// What actually reaches the transport, counted.
///
/// The other sink test holds the pure functions — the whitelist, the redaction,
/// the breadcrumb trim — which is where the CONTENT rules live. This one holds
/// the rule underneath them: how MANY envelopes leave, for which levels, and
/// with which tags. Nothing else in the suite could tell the difference between
/// "captured once" and "captured twice", and captured twice is exactly what the
/// SDK's own error integrations did before `configureOptions` removed them.
///
/// A real hub, over a fake transport: `Sentry.init` on the VM needs no platform
/// channels, and the SDK's own default integrations are dropped in the same
/// callback — `IsolateErrorIntegration` would otherwise record the test
/// runner's own failures into the recorder.
final class _Recorder implements Transport {
  final List<SentryEnvelope> envelopes = <SentryEnvelope>[];

  @override
  Future<SentryId?> send(SentryEnvelope envelope) async {
    envelopes.add(envelope);
    return envelope.header.eventId;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Recorder recorder;
  late Telemetry telemetry;
  late SentryTelemetry sink;

  setUp(() async {
    recorder = _Recorder();
    telemetry = Telemetry(runId: 'run-1');
    sink = SentryTelemetry(
      telemetry: telemetry,
      dsn: 'https://public@example.invalid/1',
      environment: EnvironmentFlavor.development,
    );
    await Sentry.init((options) {
      options
        ..dsn = 'https://public@example.invalid/1'
        ..transport = recorder
        ..tracesSampleRate = 0
        // `Sentry.init` SWALLOWS anything this callback throws unless `automatedTestMode` is on
        // (`sentry.dart`, the `catch` around `optionsConfiguration`). It was on the default —
        // `false` — while the next line threw, so the cascade below it never ran: the integrations
        // stayed, `beforeSend`/`beforeSendLog` were never wired, and these tests passed on a hub
        // configured differently from the one they describe.
        //
        // `@internal` to the SDK and used deliberately: it is the flag the SDK provides FOR tests,
        // and there is no public equivalent.
        // ignore: invalid_use_of_internal_member
        ..automatedTestMode = true
        ..beforeSend = SentryTelemetry.redactEvent
        ..beforeSendLog = SentryTelemetry.redactLog;
      // Only the ERROR integrations, and not through `options.integrations.clear()` — the getter
      // returns `List.unmodifiable`, so that call threw. `IsolateErrorIntegration` would record
      // the runner's own failures into the recorder; the rest MUST survive, because
      // `LoggerSetupIntegration` and `InMemoryTelemetryProcessorIntegration` are what give
      // `Sentry.logger.*` — and therefore `..escalate()` — somewhere to go. Matched by NAME, which
      // production must never do (an obfuscated build has none) and a test binary always can:
      // `IsolateErrorIntegration` is not exported, so there is no type to match on here.
      for (final integration
          in options.integrations.where((i) => '${i.runtimeType}'.endsWith('ErrorIntegration')).toList()) {
        options.removeIntegration(integration);
      }
    });
    sink.attach();
    await sink.tagRunId();
  });

  tearDown(() async {
    await telemetry.close();
    await Sentry.close();
  });

  Future<List<SentryEvent>> captured() async {
    // Pump FIRST: a cascade's channel actions are resolved after the last one is
    // written, so the escalation has not been dispatched yet. Then `settle()` —
    // the sink drops its capture future (a crash report never blocks the failing
    // path) and the SDK's own future makes no progress until something awaits it.
    await pumpEventQueue();
    await sink.settle();
    final events = <SentryEvent>[];
    for (final envelope in recorder.envelopes) {
      for (final item in envelope.items) {
        // The item type is a bare string in the envelope protocol; `event` is the only one an
        // `captureException` produces, and a `log` item is what an escalated warning becomes.
        if (item.header.type != 'event') continue;
        if (await _decode(item) case final event?) events.add(event);
      }
    }
    return events;
  }

  test('a warning is journaled and NOT captured', () async {
    telemetry.w('Auth | signIn | failed');
    expect(await captured(), isEmpty);
  });

  test('an error is captured exactly once, tagged with the run id', () async {
    telemetry.e('Auth | signIn | failed', error: StateError('disk'));
    final events = await captured();
    expect(events, hasLength(1));
    expect(events.single.tags?['run_id'], 'run-1');
  });

  test('only whitelisted attributes become tags', () async {
    telemetry.e(
      'Control | handler | failed',
      error: StateError('disk'),
      meta: <String, Object?>{'control.controller': 'UserController', 'control.from': 'User(id: 42)'},
    );
    final tags = (await captured()).single.tags ?? const <String, String>{};
    expect(tags['control.controller'], 'UserController');
    expect(tags.containsKey('control.from'), isFalse, reason: 'a state rendering carries the user');
  });

  group('cascade order does not change what is sent', () {
    test('..escalate() then ..error() captures once', () async {
      telemetry('Auth | signIn | failed')
        ..cause(StateError('disk'))
        ..escalate()
        ..error();
      expect(await captured(), hasLength(1));
    });

    test('..error() then ..escalate() captures once', () async {
      telemetry('Auth | signIn | failed')
        ..cause(StateError('disk'))
        ..error()
        ..escalate();
      expect(await captured(), hasLength(1));
    });

    test('..warn() with escalate(level: .error) captures once', () async {
      telemetry('Auth | signIn | failed')
        ..cause(StateError('disk'))
        ..warn()
        ..escalate(level: .error);
      expect(await captured(), hasLength(1));
    });
  });

  test('the same failure twice is one issue — the throttle is on the path, not beside it', () async {
    // `ReportThrottle` is unit-tested in the package; what was never tested is that the SINK
    // consults it. A backend that is down for ten minutes is the shape it exists for: one issue,
    // not one per retry.
    final boom = StateError('socket');
    telemetry
      ..e('Auth | signIn | failed', error: boom)
      ..e('Auth | signIn | failed', error: boom);

    expect(await captured(), hasLength(1), reason: 'same site, same error type, inside the dedupe window');
  });

  test('two different failures are two issues', () async {
    telemetry
      ..e('Auth | signIn | failed', error: StateError('socket'))
      ..e('Auth | refresh | failed', error: ArgumentError('nope'));

    expect(await captured(), hasLength(2));
  });

  test('an escalated warning travels as a structured LOG, never as an issue', () async {
    telemetry('Rpc | call | failed')
      ..meta(<String, Object?>{'rpc.path': '/auth.v1/SignIn'})
      ..warn()
      ..escalate();
    await pumpEventQueue();
    await sink.settle();

    expect(await captured(), isEmpty, reason: 'a warning is not an issue');
    // That it still TRAVELS is not asserted here: a structured log is batched by the SDK
    // (`TelemetryBufferConfig`, five seconds) and never reaches this transport within a test.
    // What makes it travel is one option, and that is pinned where it is set —
    // `sentry_sink_test.dart`, "state the privacy stance explicitly" (`enableLogs`).
  });
  test('the SDK\'s own error integrations are removed, so nothing captures twice', () {
    // BOTH pre-loaded, as `SentryFlutter.init` loads them before our callback. The first version
    // of this test loaded only one, so half of the assertion could not fail — and the removal it
    // did not check was matched by class NAME, which an obfuscated release build does not have.
    final options = SentryFlutterOptions()
      ..addIntegration(FlutterErrorIntegration())
      ..addIntegration(OnErrorIntegration());
    sink.configureOptions(options);
    expect(
      options.integrations.whereType<OnErrorIntegration>(),
      isEmpty,
      reason: 'chains the platform handler the app installed and captures at fatal, unthrottled',
    );
    expect(
      options.integrations.whereType<FlutterErrorIntegration>(),
      isEmpty,
      reason: 'chains FlutterError.onError the same way; matched by type so obfuscation cannot hide it',
    );
  });
}

Future<SentryEvent?> _decode(SentryEnvelopeItem item) async {
  final data = await item.dataFactory();
  return SentryEvent.fromJson(_json(data));
}

Map<String, dynamic> _json(List<int> data) => Map<String, dynamic>.from(jsonDecode(utf8.decode(data)) as Map);
