import 'package:auth_app/_core/api/_core/sentry_redaction.dart';
import 'package:auth_app/_core/api/_core/sentry_tracing.dart';
import 'package:auth_model/auth_model.dart';
import 'package:connect_model/connect_model.dart';
import 'package:connectrpc/connect.dart';
import 'package:meta/meta.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// {@template connect_sentry_middleware}
/// Middleware for Sentry integration in API requests.
/// [ConnectSentryMiddleware] middleware captures Connect RPC requests and responses, creating a
/// transaction for each request to monitor performance and errors.
/// {@endtemplate}
@immutable
class ConnectSentryMiddleware extends ConnectMiddleware {
  /// {@macro connect_sentry_middleware}
  const ConnectSentryMiddleware();

  @override
  ConnectMiddlewareHandler handle(ConnectMiddlewareHandler invoker) => (path, metadata) async {
    final startTimestamp = DateTime.now().toUtc();
    // Attach to the active transaction as a child span when one exists, otherwise start a new
    // root transaction — avoids orphaned/duplicate `connect.client` spans (mirrors the HTTP
    // middleware).
    final current = Sentry.getSpan();
    final transaction =
        (current?.startChild('connect.client', description: path, startTimestamp: startTimestamp) ??
              Sentry.startTransaction(
                'connect.client',
                path,
                description: path,
                bindToScope: true,
                startTimestamp: startTimestamp,
              ))
          ..setData('path', path)
          ..setData('request_headers', redactSensitiveHeaders(metadata));

    // Propagate the trace to the backend so the span continues across services (distributed tracing).
    final tracedMetadata = Map<String, String>.of(metadata);
    applyTraceHeaders(transaction, tracedMetadata);

    try {
      await invoker(path, tracedMetadata);
      // RPC OK (0), not HTTP 200; key renamed from 'grpc.response.status_code' with the transport.
      transaction.setData('rpc.response.status_code', 0);
      if (!transaction.finished) transaction.finish(status: const SpanStatus.ok()).ignore();
    } on Object catch (e, s) {
      // Expected teardown (cancellation; a request that outlived its session — A27): no Sentry
      // issue; the span still finishes and the error rethrows.
      final expectedTeardown = (e is ConnectException && e.code == .canceled) || e is RequestSessionEndedException;
      if (!expectedTeardown) {
        await Sentry.captureException(
          e,
          stackTrace: s,
          withScope: (scope) => scope.span = transaction,
          hint: Hint.withMap({
            'path': path,
            'headers': redactSensitiveHeaders(metadata),
          }),
        );
      }

      if (!transaction.finished) {
        transaction.finish(status: _spanStatusFor(e), endTimestamp: DateTime.now().toUtc()).ignore();
      }
      rethrow;
    }
  };

  /// Maps a thrown error to the Sentry [SpanStatus] used to finish the transaction. Mirrors the
  /// HTTP `HttpSentryMiddleware._spanStatusFor` for cross-transport symmetry (A8-adjacent).
  static SpanStatus _spanStatusFor(Object e) => switch (e) {
    ConnectException(:final code) when code == .unavailable => const .unavailable(),
    ConnectException(:final code) when code == .unimplemented => const .unimplemented(),
    ConnectException(:final code) when code == .internal => const .internalError(),
    ConnectException(:final code) when code == .resourceExhausted => const .resourceExhausted(),
    ConnectException(:final code) when code == .aborted => const .aborted(),
    ConnectException(:final code) when code == .notFound => const .notFound(),
    ConnectException(:final code) when code == .permissionDenied => const .permissionDenied(),
    ConnectException(:final code) when code == .unauthenticated => const .unauthenticated(),
    ConnectException(:final code) when code == .failedPrecondition => const .failedPrecondition(),
    ConnectException(:final code) when code == .canceled => const .cancelled(),
    ConnectException(:final code) when code == .deadlineExceeded => const .deadlineExceeded(),
    RequestSessionEndedException() => const .cancelled(),
    _ => const .unknownError(),
  };
}
