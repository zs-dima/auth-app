import 'package:auth_app/_core/api/_core/sentry_redaction.dart';
import 'package:auth_app/_core/api/_core/sentry_tracing.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_model/grpc_model.dart';
import 'package:meta/meta.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// {@template grpc_sentry_middleware}
/// Middleware for Sentry integration in API requests.
/// [GrpcSentryMiddleware] middleware captures gRPC requests and responses, creating a transaction
/// for each request to monitor performance and errors.
/// {@endtemplate}
@immutable
class GrpcSentryMiddleware extends GrpcMiddleware {
  /// {@macro grpc_sentry_middleware}
  const GrpcSentryMiddleware();

  @override
  GrpcMiddlewareHandler call(GrpcMiddlewareHandler invoker) => (path, metadata) async {
    final startTimestamp = DateTime.now().toUtc();
    // Attach to the active transaction as a child span when one exists, otherwise start a new
    // root transaction — avoids orphaned/duplicate `grpc.client` spans (mirrors the HTTP middleware).
    final current = Sentry.getSpan();
    final transaction =
        (current?.startChild('grpc.client', description: path, startTimestamp: startTimestamp) ??
              Sentry.startTransaction(
                'grpc.client',
                path,
                description: path,
                bindToScope: true,
                startTimestamp: startTimestamp,
              ))
          // ..setData('grpc-request.method', request.method)
          // ..setData('url', request.url.toString())
          // ..setData('method', request.method)
          ..setData('path', path)
          // ..setData('query', request.url.queryParameters)
          ..setData('request_headers', redactSensitiveHeaders(metadata));

    // Propagate the trace to the backend so the span continues across services (distributed tracing).
    final tracedMetadata = Map<String, String>.of(metadata);
    applyTraceHeaders(transaction, tracedMetadata);

    try {
      await invoker(path, tracedMetadata);
      transaction.setData('grpc.response.status_code', StatusCode.ok); // gRPC OK (0), not HTTP 200
      if (!transaction.finished) transaction.finish(status: const SpanStatus.ok()).ignore();
    } on Object catch (e, s) {
      // Cancellation is an expected event (session/screen closed), not a bug — don't spam Sentry
      // issues with it; the span is still finished (with a `cancelled` status) and the error rethrown.
      if (e is! GrpcError || e.code != StatusCode.cancelled) {
        await Sentry.captureException(
          e,
          stackTrace: s,
          withScope: (scope) => scope.span = transaction,
          hint: Hint.withMap({
            // 'method': request.method,
            // 'url': request.url,
            'path': path,
            // 'query': request.url.queryParameters,
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
    GrpcError(:final code) when code == StatusCode.unavailable => const .unavailable(),
    GrpcError(:final code) when code == StatusCode.unimplemented => const .unimplemented(),
    GrpcError(:final code) when code == StatusCode.internal => const .internalError(),
    GrpcError(:final code) when code == StatusCode.resourceExhausted => const .resourceExhausted(),
    GrpcError(:final code) when code == StatusCode.aborted => const .aborted(),
    GrpcError(:final code) when code == StatusCode.notFound => const .notFound(),
    GrpcError(:final code) when code == StatusCode.permissionDenied => const .permissionDenied(),
    GrpcError(:final code) when code == StatusCode.unauthenticated => const .unauthenticated(),
    GrpcError(:final code) when code == StatusCode.failedPrecondition => const .failedPrecondition(),
    GrpcError(:final code) when code == StatusCode.cancelled => const .cancelled(),
    GrpcError(:final code) when code == StatusCode.deadlineExceeded => const .deadlineExceeded(),
    GrpcError(:final code) when code == StatusCode.ok => const .ok(),
    _ => const .unknownError(),
  };
}
