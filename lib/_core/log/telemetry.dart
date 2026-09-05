import 'package:auth_app/_core/log/console.dart';
import 'package:flutter/foundation.dart';
import 'package:telemetry/telemetry.dart';
import 'package:uuid/uuid.dart';

export 'package:telemetry/telemetry.dart';

/// The console sink attached to [log] from the first line of `main`.
///
/// Named, rather than built inline, so a test suite can take it away: a suite
/// that drives failing repositories on purpose has no use for hundreds of lines
/// of correctly-working error handling, and `package:test` runs every test body
/// in a fresh zone, so the zone-scoped `TelemetryOptions` that would silence it
/// never reach one. `test/flutter_test_config.dart` removes this.
final ConsoleSink consoleSink = ConsoleSink(options: kConsoleOptions);

/// The app's telemetry facade.
///
/// One event describes what happened; the channels it reaches are named at the
/// call site:
///
/// ```dart
/// log('Auth | signIn | rejected')
///     .meta({'auth.reason': reason})
///     .cause(error)
///     .description(l10n.signInFailed)
///   ..warn()
///   ..toast(tone: ToastTone.alert);
/// ```
///
/// Sinks are attached during initialization: the console from this line, then
/// the journal and the crash reporter as the composition reaches them. Until
/// the journal exists the ring buffer holds everything from `debug` up, and the
/// journal DRAINS it when it opens — so the boot sequence is in the table a
/// tester's bug report is made of, not only in a console nobody kept.
final Telemetry log = Telemetry(runId: const Uuid().v4())..addSink(consoleSink);

/// Records a framework error reported through [FlutterError.onError].
///
/// One body for every framework error, with the library and the phase as
/// ATTRIBUTES. Interpolated they made `Flutter | widgets library | while
/// building MyWidget` — a distinct crash-reporter issue per widget, and a
/// throttle key that never matched twice.
void logFlutterError(FlutterErrorDetails details) =>
    log('Flutter | framework | error')
        .name('flutter.framework.error')
        .cause(details.exception, details.stack)
        .meta(<String, Object?>{
          if (details.library case final String library) 'flutter.library': library,
          if (details.context?.toDescription() case final String context) 'flutter.context': context,
          if (details.silent) 'flutter.silent': true,
        })
        .error();

/// Records an error from [PlatformDispatcher.onError]; returns `true` so the
/// platform treats it as handled, which it is.
///
/// Composed here rather than through `Telemetry.logPlatformError` so the event
/// carries a name: the throttle dedupes on it and the reporter fingerprints on
/// it, which is what keeps one uncaught failure to one issue.
bool logPlatformError(Object error, StackTrace stackTrace) {
  log('Platform | uncaught | error').name('platform.uncaught.error').cause(error, stackTrace).error();
  return true;
}

/// Records an uncaught error escaping the app's zone.
void logZoneError(Object error, StackTrace stackTrace) =>
    log('Zone | uncaught | error').name('zone.uncaught.error').cause(error, stackTrace).error();
