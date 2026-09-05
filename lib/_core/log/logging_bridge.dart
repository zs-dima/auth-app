import 'dart:async';

import 'package:auth_app/_core/log/telemetry.dart';
import 'package:logging/logging.dart' as logging;

/// Forwards `package:logging` records into the pipeline.
///
/// One package in this app's tree logs that way — `cupertino_http`, the Darwin
/// URLSession transport — and without this its lines go nowhere at all: the
/// package writes to `Logger.root` and nothing in this app ever listened. A
/// transport that says "the session invalidated" and is not heard is exactly
/// the kind of thing an unexplained failure turns out to have been.
///
/// Levels map by number, not by name: both scales are the `dart:developer` one
/// (FINEST 300 … SHOUT 1200), so the arithmetic is the translation.
final class LoggingBridge {
  /// Starts forwarding. [level] is what `package:logging` itself will emit;
  /// leave it at `INFO` unless something is being chased.
  LoggingBridge({logging.Level level = logging.Level.INFO}) {
    logging.Logger.root.level = level;
    _subscription = logging.Logger.root.onRecord.listen(_forward, cancelOnError: false);
  }

  StreamSubscription<logging.LogRecord>? _subscription;

  void _forward(logging.LogRecord record) {
    // The BODY is fixed; the logger and the text are attributes. A `SEVERE` record
    // with no error used to become an issue whose exception value was the free
    // text, so every distinct sentence was its own fingerprint and its own
    // breadcrumb category — the interpolated-body defect, arriving from a
    // package we do not own. And a record without an error is capped at `warn`:
    // a third party's idea of severe is not this app's incident.
    final level = _level(record.level.value);
    final effective = record.error == null && level >= .error ? LogLevel.warn : level;
    if (!log.isEnabled(effective)) return;
    // `emit`, not a draft: this is the OpenTelemetry bridge shape, and it is the
    // only way the record keeps the time IT was written rather than the time we
    // heard about it.
    log.emit(
      LogEvent(
        level: effective,
        body: 'Logging | forwarded | record',
        name: 'logging.forwarded.${record.loggerName}',
        timestamp: record.time.toUtc(),
        sequence: log.nextSequence(),
        runId: log.runId,
        meta: <String, Object?>{
          ...log.resource,
          'log.source': 'logging',
          'log.logger': record.loggerName,
          'log.message': record.message,
        },
        error: record.error,
        stackTrace: record.stackTrace,
      ),
    );
  }

  /// Both scales are `dart:developer`'s, so the boundaries are its own.
  static LogLevel _level(int value) => switch (value) {
    >= 1200 => .fatal,
    >= 1000 => .error,
    >= 900 => .warn,
    >= 800 => .info,
    >= 500 => .debug,
    _ => .trace,
  };

  /// Stops forwarding.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
