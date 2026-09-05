// Shared canonical lines for the Connect + HTTP logger middlewares, so neither the bodies nor the
// attribute names can drift between transports (the same DRY rationale as sentry_redaction.dart /
// sentry_tracing.dart).

import 'package:auth_app/_core/log/telemetry.dart';

/// Logs one canonical line for a finished transport call.
///
/// The body is the grouping key and carries nothing variable — `Rpc | call | ok`,
/// `Http | call | failed` — while the path, the code and the duration ride as attributes. That is
/// what lets the crash reporter group a failure by kind and a query count its instances; a body
/// with the path interpolated into it would group into one issue per endpoint instead (Stripe's
/// canonical log line, OpenTelemetry's attribute naming).
///
/// One event per CALL, never per attempt: both loggers sit outermost, so what [elapsedMs] measures
/// is the whole logical call including any retries. The retries themselves are reported separately
/// by [logTransportRetry], wired to each retry middleware's `onRetry`.
void logTransportCall({
  required String area,
  required String outcome,
  required Map<String, Object?> meta,
  required int elapsedMs,
  LogLevel level = .info,
  Object? error,
  StackTrace? stackTrace,
}) {
  log('$area | call | $outcome')
      .meta(<String, Object?>{...meta, 'net.duration_ms': elapsedMs})
      .cause(error, stackTrace)
      .at(level);
}

/// Logs one retry of a transport call, from a retry middleware's `onRetry`.
///
/// [attempt] is the middleware's 0-based index of the attempt that just failed, reported as the
/// human count (`net.attempt: 1` for the first failure). `debug`, not `warn`: a retried transient
/// failure is the retry policy working, and the call's own line says how it ended.
void logTransportRetry({
  required String area,
  required Object error,
  required int attempt,
  required Duration delay,
}) => log(
  '$area | call | retry',
).meta(<String, Object?>{'net.attempt': attempt + 1, 'net.retry_delay_ms': delay.inMilliseconds}).cause(error).debug();
