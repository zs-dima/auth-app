import 'package:auth_app/_core/environment/model/environment.dart';
import 'package:auth_app/_core/log/sentry_sink.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// What may leave the device, and what may not.
///
/// No Sentry hub here on purpose. `enableReporting` refuses in a debug build
/// (which every test is), and the interesting decisions are not in the SDK
/// anyway — they are the whitelist, the redaction and the breadcrumb shape,
/// each of which is a pure function this holds directly. The one thing that
/// needs the SDK is the option wiring, and that is asserted by applying the
/// app's own [SentryTelemetry.configureOptions] to a bare options object.
void main() {
  LogEvent event({
    LogLevel level = LogLevel.error,
    String body = 'Rpc | call | failed',
    Map<String, Object?> meta = const <String, Object?>{},
    Object? error,
  }) => LogEvent(
    level: level,
    body: body,
    timestamp: DateTime.utc(2026, 9, 3),
    runId: 'run-1',
    meta: meta,
    error: error,
  );

  group('tags', () {
    test('carry the technical attributes an issue is triaged by', () {
      final tags = SentryTelemetry.tagsFor(
        event(meta: <String, Object?>{'rpc.path': '/auth.v1/SignIn', 'rpc.code': 'internal', 'net.attempt': 2}),
      );

      expect(tags, <String, String>{'rpc.path': '/auth.v1/SignIn', 'rpc.code': 'internal', 'net.attempt': '2'});
    });

    test('never carry a state rendering, a user id, or the exception message', () {
      // The defect: `event.attributes` went to `scope.setContexts` wholesale, so
      // a controller transition shipped both whole states, and every captured
      // failure shipped `exception.message` — which is where a backend's words
      // about a real person live.
      final tags = SentryTelemetry.tagsFor(
        event(
          meta: <String, Object?>{
            'control.controller': 'UsersController',
            'control.from': 'IdleState(user: alice@example.com)',
            'control.to': 'ErrorState(cause: alice@example.com not found)',
            'app.user.id': 'a7f1c8d2-0000-4000-8000-000000000001',
            'auth.reason': 'wrong password',
          },
          error: StateError('alice@example.com already exists'),
        ),
      );

      expect(tags.keys, <String>['control.controller']);
      expect(tags.toString(), isNot(contains('alice')));
      expect(tags.keys, isNot(contains('exception.message')));
      expect(tags.keys, isNot(contains('exception.stacktrace')));
    });

    test('an HTTP failure ships the host, never the object path', () {
      // The only ApiClient in this app talks to S3, and its object keys are
      // `users/<userId>/avatar.webp` — so `http.route` IS a user id. The host is what a triage
      // question ("which service?") actually needs; the journal keeps the route locally.
      final tags = SentryTelemetry.tagsFor(
        event(
          body: 'Http | call | failed',
          meta: <String, Object?>{
            'http.method': 'PUT',
            'http.host': 's3.example.com',
            'http.route': '/users/a7f1c8d2-0000-4000-8000-000000000001/avatar.webp',
            'http.status_code': 403,
          },
        ),
      );

      expect(tags.keys, isNot(contains('http.route')));
      expect(tags.toString(), isNot(contains('a7f1c8d2')));
      expect(tags, <String, String>{'http.method': 'PUT', 'http.host': 's3.example.com', 'http.status_code': '403'});
    });

    test('an unknown key is dropped, not shipped', () {
      // A whitelist because the failure mode of a blacklist is silent.
      final tags = SentryTelemetry.tagsFor(event(meta: <String, Object?>{'app.something.new': 'whatever'}));
      expect(tags, isEmpty);
    });
  });

  group('redaction', () {
    test('an e-mail address in an exception message never leaves', () {
      expect(
        SentryTelemetry.redactText('AlreadyExists: user alice.smith+work@example.co.uk already registered'),
        'AlreadyExists: user [email] already registered',
      );
    });

    test('applies to the exception value and to the message of an outgoing event', () {
      final outgoing = SentryEvent(
        message: SentryMessage('signup failed for bob@example.com'),
        exceptions: <SentryException>[
          SentryException(type: 'ConnectException', value: 'already_exists: carol@example.com'),
        ],
      );

      final redacted = SentryTelemetry.redactEvent(outgoing);

      expect(redacted.exceptions?.single.value, 'already_exists: [email]');
      expect(redacted.message?.formatted, 'signup failed for [email]');
      expect(redacted.exceptions?.single.type, 'ConnectException', reason: 'the type is the grouping key');
    });

    test('a structured log keeps only whitelisted attributes', () {
      final record = SentryLog(
        timestamp: DateTime.utc(2026, 9, 3),
        traceId: const SentryId.empty(),
        level: SentryLogLevel.warn,
        body: 'Rpc | call | failed for dave@example.com',
        attributes: <String, SentryAttribute>{
          'rpc.code': SentryAttribute.string('unavailable'),
          'control.to': SentryAttribute.string('ErrorState(dave@example.com)'),
        },
      );

      final redacted = SentryTelemetry.redactLog(record);

      expect(redacted.body, 'Rpc | call | failed for [email]');
      expect(redacted.attributes.keys, <String>['rpc.code']);
    });
  });

  group('breadcrumbs', () {
    test('use the area as the category, so a trail can be read by subsystem', () {
      final crumb = SentryTelemetry.breadcrumbFor(event(level: .info, body: 'Auth | signIn | ok'));

      expect(crumb.category, 'Auth');
      expect(crumb.message, 'Auth | signIn | ok');
      expect(crumb.level, SentryLevel.info);
      expect(crumb.timestamp, DateTime.utc(2026, 9, 3));
    });

    test('a body with no separators falls back to one shared category', () {
      // A bridged line or a captured `print` names no subsystem, and a category
      // made of the message would give the trail one category per line.
      final crumb = SentryTelemetry.breadcrumbFor(event(level: .info, body: 'something happened'));
      expect(crumb.category, 'log');
      expect(crumb.message, 'something happened', reason: 'the line itself is still the crumb');
    });
  });

  group('options', () {
    late SentryFlutterOptions options;

    setUp(() {
      options = SentryFlutterOptions();
      SentryTelemetry(
        telemetry: Telemetry(runId: 'run-1'),
        dsn: 'https://public@example.invalid/1',
        environment: EnvironmentFlavor.development,
      ).configureOptions(options);
    });

    test('state the privacy stance explicitly rather than inheriting a default', () {
      expect(options.replay.sessionSampleRate, 0.0, reason: 'a replay records e-mails and names');
      expect(options.replay.onErrorSampleRate, 0.0);
      expect(options.sendDefaultPii, isFalse);
      expect(options.enableAutoSessionTracking, isFalse, reason: 'a session carries a per-install id');
      expect(
        options.enablePrintBreadcrumbs,
        isFalse,
        reason: 'DebugPrintIntegration replaces debugPrint in release: an unredacted breadcrumb, printed nowhere',
      );
      expect(
        options.enableLogs,
        isTrue,
        reason: 'Sentry.logger.* — how `..sentry()` ships a structured log — is a no-op without it',
      );
    });

    test('wire the redaction of everything the app does not compose', () {
      expect(options.beforeSend, isNotNull, reason: 'an exception message is not ours to trust');
      expect(options.beforeSendLog, isNotNull);
      expect(options.beforeBreadcrumb, isNotNull, reason: 'the SDK adds breadcrumbs of its own');
    });

    test('the DSN and the environment come from the caller, not from a define', () {
      expect(options.dsn, 'https://public@example.invalid/1');
      expect(options.environment, EnvironmentFlavor.development.value);
    });
  });

  group("the SDK's own breadcrumbs", () {
    test('keep the route NAMES and drop the route ARGUMENTS', () {
      // `SentryNavigatorObserver` writes `from`/`to`/`state` plus `from_arguments`/`to_arguments`.
      // The names are the trail — which screen the user was on is the question a crash report is
      // read with. The arguments are where a value rides: a pairing code, a reset token.
      //
      // This used to `data.clear()`, which left a stream of blank `navigation` crumbs: the
      // arguments were gone and so was every word of the trail.
      final crumb = SentryTelemetry.trimBreadcrumbData(
        Breadcrumb(
          category: 'navigation',
          data: <String, Object?>{
            'from': '/panel',
            'to': '/pairing',
            'state': 'push',
            'to_arguments': <String, Object?>{'code': '4821'},
          },
        ),
      );

      expect(crumb?.data?['from'], '/panel');
      expect(crumb?.data?['to'], '/pairing');
      expect(crumb?.data?['state'], 'push');
      expect(crumb?.data?.containsKey('to_arguments'), isFalse);
    });
  });

  group('the debug gate', () {
    test('refuses to start the production project from a debug build', () async {
      // The `kDebugMode` gate used to live only in the init step, so the settings switch was a
      // path around it: a developer flipping it filed every experiment against the release
      // backlog. Every test runs in debug, which is what makes this assertable at all.
      final telemetry = Telemetry(runId: 'run-1');
      final recorded = <LogEvent>[];
      final subscription = telemetry.events.listen(recorded.add);
      addTearDown(subscription.cancel);

      var initialized = false;
      final sink = SentryTelemetry(
        telemetry: telemetry,
        dsn: 'https://public@example.invalid/1',
        environment: EnvironmentFlavor.development,
        init: (configure) async => initialized = true,
      );
      await sink.enableReporting();

      expect(initialized, isFalse);
      expect(Sentry.isEnabled, isFalse);
      expect(
        recorded.map((e) => e.body),
        contains('Sentry | init | refused in a debug build'),
        reason: 'silence would read as "reporting is on"',
      );
    });
  });
}
