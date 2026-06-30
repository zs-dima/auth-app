import 'package:auth_app/_core/api/_core/sentry_redaction.dart';
import 'package:auth_app/_core/api/_core/sentry_tracing.dart';
import 'package:http_client/http_client.dart';
import 'package:meta/meta.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// {@template sentry_middleware}
/// Middleware for Sentry integration in API requests.
/// [HttpSentryMiddleware] middleware captures HTTP requests and responses, creating a transaction
/// for each request to monitor performance and errors.
/// {@endtemplate}
@immutable
class HttpSentryMiddleware {
  /// {@macro sentry_middleware}
  const HttpSentryMiddleware({this.propagateTrace = true});

  /// Whether to inject `sentry-trace`/`baggage` headers into the outgoing request for
  /// distributed tracing. Keep `true` for first-party services; set `false` for third-party
  /// hosts (e.g. an S3 presigned upload) so internal trace IDs / baggage don't leak off-domain.
  /// The Sentry span + error capture (monitoring) still run regardless.
  final bool propagateTrace;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    final operation = context['operation']?.toString() ?? '[${request.method}] ${request.url.path}';
    final startTimestamp = DateTime.now().toUtc();
    // Attach to the active transaction as a child span when one exists, otherwise
    // start a new root transaction — avoids orphaned/duplicate `http.client` spans.
    final current = Sentry.getSpan();
    final transaction =
        (current?.startChild('http.client', description: operation, startTimestamp: startTimestamp) ??
              Sentry.startTransaction(
                'http.client',
                operation,
                description: operation,
                bindToScope: true,
                startTimestamp: startTimestamp,
              ))
          ..setData('http.request.method', request.method)
          ..setData('url', request.url.toString())
          ..setData('path', request.url.path)
          ..setData('query', redactSensitiveQuery(request.url.queryParametersAll))
          ..setData('request_headers', redactSensitiveHeaders(request.headers));

    // Propagate the trace to the backend so the span continues across services (distributed
    // tracing). Skipped for third-party hosts ([propagateTrace] = false) to avoid leaking
    // internal trace IDs / baggage off-domain.
    if (propagateTrace) applyTraceHeaders(transaction, request.headers);

    try {
      final response = await innerHandler(request, context);
      transaction.setData('http.response.status_code', response.statusCode);
      if (!transaction.finished) transaction.finish(status: const SpanStatus.ok()).ignore();
      return response;
    } on Object catch (e, s) {
      // Cancellation is an expected event (session/screen closed), not a bug — don't spam Sentry
      // issues with it; the span is still finished (with a `cancelled` status) and the error rethrown.
      if (e is! ApiClientException$Cancelled) {
        await Sentry.captureException(
          e,
          stackTrace: s,
          withScope: (scope) => scope.span = transaction,
          hint: Hint.withMap({
            'method': request.method,
            'url': request.url,
            'path': request.url.path,
            'query': redactSensitiveQuery(request.url.queryParametersAll),
            'headers': redactSensitiveHeaders(request.headers),
          }),
        );
      }

      if (!transaction.finished) {
        transaction.finish(status: _spanStatusFor(e), endTimestamp: DateTime.now().toUtc()).ignore();
      }
      rethrow;
    }
  };

  /// Maps a thrown error to the Sentry [SpanStatus] used to finish the transaction.
  static SpanStatus _spanStatusFor(Object e) => switch (e) {
    ApiClientException(statusCode: 503) => const SpanStatus.unavailable(),
    ApiClientException(statusCode: 501) => const SpanStatus.unimplemented(),
    ApiClientException(statusCode: 500) => const SpanStatus.internalError(),
    ApiClientException(statusCode: 429) => const SpanStatus.resourceExhausted(),
    ApiClientException(statusCode: 409) => const SpanStatus.aborted(),
    ApiClientException(statusCode: 404) => const SpanStatus.notFound(),
    ApiClientException(statusCode: 403) => const SpanStatus.permissionDenied(),
    ApiClientException(statusCode: 401) => const SpanStatus.unauthenticated(),
    ApiClientException(statusCode: 400) => const SpanStatus.failedPrecondition(),
    ApiClientException$Cancelled() => const SpanStatus.cancelled(),
    ApiClientException(statusCode: < 400) => const SpanStatus.unknownError(),
    ApiClientException(:final statusCode) => SpanStatus.fromHttpStatusCode(statusCode),
    _ => const SpanStatus.unknownError(),
  };
}
