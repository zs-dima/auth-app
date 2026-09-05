import 'dart:async';

import 'package:auth_app/_core/environment/model/environment.dart';
import 'package:auth_model/auth_model.dart' show RpcException;
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
// The one integration the SDK does not export, imported so it can be matched by TYPE (see
// `configureOptions`). The version is pinned in pubspec; a bump reviews this line by hand.
// ignore: implementation_imports
import 'package:sentry_flutter/src/integrations/flutter_error_integration.dart';
import 'package:telemetry/telemetry.dart';

/// {@template crash_reporting}
/// Turns crash reporting on and off.
/// {@endtemplate}
abstract interface class CrashReporting {
  /// Starts reporting. Called when the user has opted in.
  Future<void> enableReporting();

  /// Stops reporting. Called when the user has opted out.
  Future<void> disableReporting();
}

/// Starts the Sentry SDK. A seam: tests pass a recorder instead.
typedef SentryInitializer = Future<void> Function(FlutterOptionsConfiguration configure);

/// {@template sentry_telemetry}
/// The Sentry end of the telemetry pipeline.
///
/// `ReportingSink` owns the policy — breadcrumbs from `info` up, issues from
/// `error` up through a dedupe and a rate limit, an explicit `..escalate()` on
/// a lighter event as a structured log rather than an issue. That last
/// distinction is the whole reason warnings stopped being issues: a ten-minute
/// network outage used to produce one issue per retry. The three hooks below
/// are the only part that knows Sentry (Sentry keeps its own breadcrumb ring —
/// `maxBreadcrumbs`, 100 by default — which is why we do not keep a second).
///
/// What travels with an issue is a WHITELIST ([_taggable]), never the event's
/// attributes wholesale. This is an auth app: attributes carry user ids, e-mail
/// addresses in a backend's refusal message, and raw state renderings. The
/// pipeline is allowed to know them; the reporter is not.
/// {@endtemplate}
final class SentryTelemetry extends ReportingSink implements CrashReporting {
  /// The attribute keys allowed to leave the device as Sentry tags.
  ///
  /// A whitelist because the failure mode of a blacklist is silent: every new
  /// `.meta({...})` key would ship until someone noticed. Everything here is a
  /// path, a code, a class name or a count — nothing a user typed, nothing that
  /// identifies a person, no state rendering (`control.from`/`control.to` carry
  /// whole objects and are deliberately absent).
  static const Set<String> _taggable = <String>{
    'rpc.path',
    'rpc.code',
    'http.method',
    // NOT `http.route`: the one HTTP client this app has talks to S3, whose object keys are
    // `users/<userId>/avatar.webp` — the path IS an identifier. The host answers the question a
    // tag is read with ("which service failed"), and the journal keeps the route either way.
    'http.host',
    'http.status_code',
    'http.error_code',
    'net.duration_ms',
    'net.attempt',
    'control.controller',
    'control.handler',
    'control.duration_ms',
    'app.boot.step',
    'app.boot.index',
    'app.boot.total',
    'app.boot.ms',
    'app.route',
    'app.lifecycle',
    'app.environment',
    'app.settings.key',
    'app.verification.code',
    'app.update.version',
    'app.image.ms',
    'app.avatar.bytes',
    'app.avatar.mime_type',
    'app.version',
    'app.version.previous',
    'db.from',
    'db.to',
    'db.implementation',
    'db.rows_deleted',
    'flutter.library',
    'flutter.context',
    'flutter.silent',
    'log.source',
    'log.logger',
    'event.name',
  };

  /// Anything shaped like an e-mail address, wherever it appears in an outgoing
  /// exception message. The backend says "user alice@example.com already
  /// exists"; the reporter does not need the address to group that.
  ///
  /// Deliberately not `\w`: that is ASCII-only without the unicode flag, so
  /// `ünïcode@example.com` would keep its prefix and lose only the tail. Anything
  /// that is not whitespace or a delimiter counts as part of the address —
  /// over-redaction here costs nothing, under-redaction costs an address.
  static final RegExp _email = RegExp(r'[^\s<>()@,;:"]+@[^\s<>()@,;:"]+\.[^\s<>()@,;:"]+');

  /// {@macro sentry_telemetry}
  SentryTelemetry({
    required this.telemetry,
    required this.dsn,
    required this.environment,
    SentryInitializer? init,
  }) : _init = init ?? SentryFlutter.init;

  final SentryInitializer _init;

  bool _reporting = false;

  /// The pipeline this sink belongs to.
  final Telemetry telemetry;

  /// Sentry DSN.
  final String dsn;

  /// Deployment flavour, reported as the Sentry environment.
  final EnvironmentFlavor environment;

  @override
  void breadcrumb(LogEvent event) => Sentry.addBreadcrumb(breadcrumbFor(event)).ignore();

  @override
  void report(LogEvent event, LogLevel level) {
    final body = event.body;
    final attributes = _attributes(event);
    switch (level) {
      case .trace:
        Sentry.logger.trace(body, attributes: attributes);

      case .debug:
        Sentry.logger.debug(body, attributes: attributes);

      case .info:
        Sentry.logger.info(body, attributes: attributes);

      case .warn:
        Sentry.logger.warn(body, attributes: attributes);

      // `error` and `fatal` never reach here: they are incidents, and the base
      // class captures them.
      case .error || .fatal:
        break;
    }
  }

  /// The start in progress, so a second caller joins it instead of starting another.
  Future<void>? _starting;

  @override
  Future<void> enableReporting() {
    if (_reporting) return Future<void>.value();
    // One start at a time. `_reporting` only flips after `_init` RETURNS, so two overlapping
    // calls — the settings switch tapped off, on, on while the native init is still running —
    // both initialized the SDK and both added this sink to the pipeline.
    return _starting ??= _start().whenComplete(() => _starting = null);
  }

  Future<void> _start() async {
    // The gate lives HERE, not only in the init step: this method is also what
    // the settings switch calls, and a debug build flipping it used to start
    // the production project and file a developer's every experiment as an
    // issue against the release backlog.
    if (kDebugMode) {
      telemetry.w('Sentry | init | refused in a debug build');
      return;
    }
    await _init(configureOptions);
    // AFTER init, not inside the options callback: the hub is built from the
    // options when `init` returns, so anything set on the scope during the
    // callback is written to the disabled hub and discarded.
    await tagRunId();
    _reporting = true;
    telemetry
      ..addSink(this)
      ..escalationSink = this
      ..traceContext = currentTrace;
  }

  /// The app's Sentry configuration.
  ///
  /// Separate from [enableReporting] so a test can apply the real options —
  /// privacy flags, `beforeSend`, `beforeSendLog` — to a hub of its own: this
  /// method is the privacy stance, and it is the thing worth pinning.
  @visibleForTesting
  void configureOptions(SentryFlutterOptions options) {
    // ONE reporter. `SentryFlutter.init` installs `FlutterErrorIntegration` and
    // `OnErrorIntegration` before this callback runs (`sentry_flutter.dart:39,47`),
    // and both CHAIN the handlers `$initializeApp` already set — so every
    // framework error was captured twice: once by the SDK at `fatal`, unthrottled
    // and with no tag whitelist, and once by us at `error`. Two issues, two
    // fingerprints, two severities. The pipeline keeps the decision.
    //
    // Matched by TYPE, never by name. `FlutterErrorIntegration` is not exported, so the first
    // version compared `runtimeType.toString()` to its class name — which an obfuscated release
    // build does not have. This app does not pass `--obfuscate` today (`tool/makefile/deploy.mk`),
    // so that was latent here and live in BreakerSonar; adding the flag would have re-armed it
    // silently. An `is` check cannot be undone by a build flag.
    for (final integration
        in options.integrations.where((i) => i is OnErrorIntegration || i is FlutterErrorIntegration).toList()) {
      options.removeIntegration(integration);
    }
    options
      ..dsn = dsn
      ..tracesSampleRate = 0.2
      // Always `false`: `enableReporting` refuses to start in a debug build, so the one
      // build this callback ever configures is a release one.
      ..debug = false
      ..environment = environment.value
      // --- Privacy stance, set EXPLICITLY rather than relying on SDK
      // defaults, because a default can change under us and this is an AUTH
      // app: events orbit real user identities. ---
      // Session Replay OFF: replays capture rendered screens — emails, names.
      ..replay.sessionSampleRate = 0.0
      ..replay.onErrorSampleRate = 0.0
      // No IP address, no device name, no user identifiers from the SDK.
      ..sendDefaultPii = false
      // Release health OFF: a session carries a persistent per-install
      // identifier (docs/decisions.md 2026-09-02).
      ..enableAutoSessionTracking = false
      // `DebugPrintIntegration` REPLACES Flutter's `debugPrint` in release and turns every call
      // into a breadcrumb — unredacted, and printed nowhere ("debugPrint is not outputting to the
      // console anymore", its own docstring). That is a second, unowned path into a report for
      // whatever any package prints; `LoggingBridge` and the print capture in `appZone` are the
      // owned ones, and both come through `beforeSend`.
      ..enablePrintBreadcrumbs = false
      // Pinned, not inherited: `Sentry.logger.*` — how `..sentry()` ships a structured log — is a
      // no-op when this is false, and the value is an SDK default on an alpha channel.
      ..enableLogs = true
      // The SDK's automatic breadcrumbs may carry raw payloads in `data`, so the
      // ARGUMENTS go — that is where a password-reset token would ride. The rest
      // stays: `SentryNavigatorObserver` puts the route names in exactly this map
      // (`from`, `to`, `state`), and clearing it wholesale left a stream of blank
      // `navigation` crumbs, which is the opposite of why the observer is wired.
      ..beforeBreadcrumb = trimBreadcrumbData
      // The last line of defence for the one string we do not compose: an
      // exception's own message.
      ..beforeSend = redactEvent
      ..beforeSendLog = redactLog
      // A cause chain groups by the failure that actually happened rather
      // than by the wrapper the transport put around it.
      ..addExceptionCauseExtractor(_RpcExceptionCauseExtractor());
  }

  /// Ties every report to the launch that produced it, so a crash can be read
  /// next to the journal rows of that run.
  ///
  /// A TAG, not `setAttributes`: attributes scope structured LOGS, and the thing
  /// that needs joining to the journal is the issue.
  Future<void> tagRunId() async => Sentry.configureScope((scope) => scope.setTag('run_id', telemetry.runId));

  @override
  Future<void> disableReporting() async {
    if (!_reporting) return;
    _reporting = false;
    telemetry.removeSink(this);
    // `Sentry.close()` below is PROCESS-global while `_reporting` is per instance: an abandoned
    // composition tearing down after a retry would close the hub the live app reports through.
    // The escalation slot is the same question, so one check answers both.
    final ours = identical(telemetry.escalationSink, this);
    if (ours) {
      telemetry
        ..escalationSink = null
        ..traceContext = null;
    }
    if (ours) await Sentry.close();
  }

  /// Registers this sink without starting the SDK. Tests only.
  @visibleForTesting
  void attach() {
    _reporting = true;
    telemetry
      ..addSink(this)
      ..escalationSink = this
      ..traceContext = currentTrace;
  }

  /// The trace in flight, for `Telemetry.traceContext`.
  ///
  /// The SDK owns the transaction; this only reads it, so a journal row and a
  /// log line can be joined to the request they belong to. Null outside one.
  @visibleForTesting
  static ({String traceId, String? spanId})? currentTrace() {
    final span = Sentry.getSpan();
    if (span == null) return null;
    return (traceId: span.context.traceId.toString(), spanId: span.context.spanId.toString());
  }

  /// Strips from an outgoing event the one string this app does not compose:
  /// an exception's own message. Wired as `beforeSend`; [hint] is unused.
  @visibleForTesting
  static SentryEvent redactEvent(SentryEvent event, [Hint? hint]) {
    for (final exception in event.exceptions ?? const <SentryException>[]) {
      final value = exception.value;
      if (value != null) exception.value = redactText(value);
    }
    if (event.message case final SentryMessage message) message.formatted = redactText(message.formatted);
    return event;
  }

  /// The same redaction for a structured log, plus the tag whitelist — an
  /// escalated warning must not carry what an issue may not. Wired as
  /// `beforeSendLog`; [hint] is unused.
  @visibleForTesting
  static SentryLog redactLog(SentryLog record, [Hint? hint]) {
    record
      ..body = redactText(record.body)
      // `sentry.*` is the SDK's own: sdk name and version, environment, release.
      // It adds them BEFORE this callback (`log_capture_pipeline.dart:31,35,41`),
      // so stripping everything unlisted would send logs with no identity at all.
      ..attributes.removeWhere((key, _) => !_taggable.contains(key) && !key.startsWith('sentry.'));
    return record;
  }

  /// The redaction itself, exposed so a test can pin it.
  @visibleForTesting
  static String redactText(String text) => text.replaceAll(_email, '[email]');

  /// Drops a breadcrumb's route ARGUMENTS, keeping its route names.
  ///
  /// `SentryNavigatorObserver` writes `from`/`to`/`state` and `*_arguments` into
  /// the same map (`sentry_navigator_observer.dart:459-463`); the names are the
  /// trail, the arguments are where a token would be.
  @visibleForTesting
  static Breadcrumb? trimBreadcrumbData(Breadcrumb? breadcrumb, [Hint? hint]) {
    breadcrumb?.data?.removeWhere((key, _) => key.endsWith('_arguments'));
    return breadcrumb;
  }

  /// The attributes of [event] that may leave the device, as Sentry tags.
  @visibleForTesting
  static Map<String, String> tagsFor(LogEvent event) => <String, String>{
    for (final MapEntry(:key, :value) in event.attributes.entries)
      // A null value as a tag says nothing and costs a row on every issue.
      if (_taggable.contains(key) && value != null) key: '$value',
  };

  /// The trail entry for [event].
  @visibleForTesting
  static Breadcrumb breadcrumbFor(LogEvent event) => .new(
    message: event.body,
    category: event.area.isEmpty ? 'log' : event.area,
    level: _sentryLevel(event.level),
    timestamp: event.timestamp,
  );

  @override
  void capture(LogEvent event, LogLevel level, StackTrace? stackTrace) {
    final sending = Sentry.captureException(
      event.error ?? event.body,
      stackTrace: stackTrace,
      withScope: (scope) async {
        scope.level = _sentryLevel(level);
        // Only when the call site named the event. `ReportThrottle` keys on that
        // name, so an issue then groups exactly as the throttle deduped; an
        // unnamed event keeps Sentry's own grouping, which is what every issue
        // filed before this line was grouped by.
        if (event.name case final String name) {
          scope.fingerprint = <String>[name, '${event.error.runtimeType}'];
        }
        for (final MapEntry(:key, :value) in tagsFor(event).entries) {
          await scope.setTag(key, value);
        }
      },
    );
    // CHAINED, not replaced: `settle()` means "every capture started so far", and a test that
    // drives two failures must be able to see both.
    _inFlight = _inFlight.then((_) => sending).then((_) {}, onError: (Object _) {});
    sending.ignore();
  }

  Future<void> _inFlight = Future<void>.value();

  /// Waits for the capture already started. Tests only.
  ///
  /// [capture] is fire-and-forget by design — a crash report must never make the failing path
  /// wait on the network — so nothing else can observe whether an envelope actually left. This is
  /// the seam that lets a test count them, and it is why the SDK's own future is kept at all.
  @visibleForTesting
  Future<void> settle() => _inFlight;

  static Map<String, SentryAttribute> _attributes(LogEvent event) => <String, SentryAttribute>{
    for (final MapEntry(:key, :value) in event.attributes.entries)
      if (_taggable.contains(key)) key: _attribute(value),
  };

  static SentryAttribute _attribute(Object? value) => switch (value) {
    final String text => .string(text),
    final bool flag => .bool(flag),
    final int number => .int(number),
    final double number => .double(number),
    null => .string(''),
    _ => .string(value.toString()),
  };

  static SentryLevel _sentryLevel(LogLevel level) => switch (level) {
    .trace || .debug => .debug,
    .info => .info,
    .warn => .warning,
    .error => .error,
    .fatal => .fatal,
  };
}

/// Reports the transport failure an [RpcException] wraps, so issues group by
/// the real cause instead of by the wrapper.
final class _RpcExceptionCauseExtractor extends ExceptionCauseExtractor<RpcException> {
  @override
  ExceptionCause? cause(RpcException error) {
    final inner = error.cause;
    return inner == null ? null : ExceptionCause(inner, null);
  }
}
