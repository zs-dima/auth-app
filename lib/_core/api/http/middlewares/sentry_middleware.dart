import 'package:auth_app/_core/api/_core/sentry_redaction.dart';
import 'package:auth_app/_core/api/_core/sentry_tracing.dart';
import 'package:http_kit/http_kit.dart';
import 'package:meta/meta.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// {@template sentry_middleware}
/// Middleware for Sentry integration in API requests.
/// [HttpSentryMiddleware] traces HTTP calls: one span per request, with the redacted url, path,
/// query and headers as span data. It does NOT report errors — see the `on Object` clause.
/// {@endtemplate}
@immutable
class HttpSentryMiddleware {
  /// {@macro sentry_middleware}
  const HttpSentryMiddleware({this.propagateTrace = true});

  /// Whether to inject `sentry-trace`/`baggage` headers into the outgoing request for
  /// distributed tracing. Keep `true` for first-party services; set `false` for third-party
  /// hosts (e.g. an S3 presigned upload) so internal trace IDs / baggage don't leak off-domain.
  /// The span still opens and closes regardless.
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
          // Redacted: a raw presigned/S3 URL is a live bearer capability (X-Amz-Signature & co).
          ..setData('url', redactSensitiveUrl(request.url))
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
    } on Object catch (e) {
      // NO capture here. This middleware owns the SPAN; whether a failure is an issue is the
      // telemetry pipeline's decision, made once, from the level the logger middleware assigns
      // and through the dedupe and rate limit that go with it. Capturing here as well filed one
      // issue per call during an outage, and a second issue with a different fingerprint for
      // anything the pipeline also reported.
      if (!transaction.finished) {
        transaction.finish(status: _spanStatusFor(e), endTimestamp: DateTime.now().toUtc()).ignore();
      }
      rethrow;
    }
  };

  /// Maps a thrown error to the Sentry [SpanStatus] used to finish the transaction.
  static SpanStatus _spanStatusFor(Object e) => switch (e) {
    ApiClientException(statusCode: 503) => const .unavailable(),
    ApiClientException(statusCode: 501) => const .unimplemented(),
    ApiClientException(statusCode: 500) => const .internalError(),
    ApiClientException(statusCode: 429) => const .resourceExhausted(),
    ApiClientException(statusCode: 409) => const .aborted(),
    ApiClientException(statusCode: 404) => const .notFound(),
    ApiClientException(statusCode: 403) => const .permissionDenied(),
    ApiClientException(statusCode: 401) => const .unauthenticated(),
    ApiClientException(statusCode: 400) => const .failedPrecondition(),
    ApiClientException$Cancelled() => const .cancelled(),
    ApiClientException(statusCode: < 400) => const .unknownError(),
    ApiClientException(:final statusCode) => .fromHttpStatusCode(statusCode),
    _ => const .unknownError(),
  };
}
