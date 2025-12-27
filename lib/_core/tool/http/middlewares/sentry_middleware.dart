import 'package:auth_app/_core/tool/http/api_client.dart';
import 'package:meta/meta.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// {@template sentry_middleware}
/// Middleware for Sentry integration in API requests.
/// [SentryMiddleware] middleware captures HTTP requests and responses, creating a transaction
/// for each request to monitor performance and errors.
/// {@endtemplate}
@immutable
class SentryMiddleware {
  /// {@macro sentry_middleware}
  const SentryMiddleware();

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    final operation = context['operation']?.toString() ?? '[${request.method}] ${request.url.path}';
    final transaction = // TODO:
        ( /*$currentSentryTransaction?.startChild(
                'http.client',
                description: operation,
                startTimestamp: DateTime.now().toUtc(),
              ) ??*/ Sentry.startTransaction(
            'http.client',
            operation,
            description: operation,
            bindToScope: true,
            startTimestamp: DateTime.now().toUtc(),
          ))
          ..setData('http-request.method', request.method)
          ..setData('url', request.url.toString())
          ..setData('method', request.method)
          ..setData('path', request.url.path)
          ..setData('query', request.url.queryParameters)
          ..setData('request_headers', request.headers);

    context['sentry.transaction'] = transaction;

    try {
      final response = await innerHandler(request, context);
      transaction.setData('http.response.status_code', response.statusCode.toString());
      if (!transaction.finished) transaction.finish(status: const SpanStatus.ok()).ignore();
      return response;
    } on Object catch (e, s) {
      await Sentry.captureException(
        e,
        stackTrace: s,
        withScope: (scope) => scope.span = transaction,
        hint: Hint.withMap({
          'method': request.method,
          'url': request.url,
          'path': request.url.path,
          'query': request.url.queryParameters,
          'headers': request.headers,
        }),
      );

      if (!transaction.finished) {
        transaction
            .finish(
              status: switch (e) {
                ApiClientException(statusCode: 503) => const SpanStatus.unavailable(),
                ApiClientException(statusCode: 501) => const SpanStatus.unimplemented(),
                ApiClientException(statusCode: 500) => const SpanStatus.internalError(),
                ApiClientException(statusCode: 429) => const SpanStatus.resourceExhausted(),
                ApiClientException(statusCode: 409) => const SpanStatus.aborted(),
                ApiClientException(statusCode: 404) => const SpanStatus.notFound(),
                ApiClientException(statusCode: 403) => const SpanStatus.permissionDenied(),
                ApiClientException(statusCode: 401) => const SpanStatus.unauthenticated(),
                ApiClientException(statusCode: 400) => const SpanStatus.failedPrecondition(),
                ApiClientException(statusCode: < 400) => const SpanStatus.unknownError(),
                ApiClientException(:final statusCode) => SpanStatus.fromHttpStatusCode(statusCode),
                _ => null,
              },
              endTimestamp: DateTime.now().toUtc(),
            )
            .ignore();
      }
      rethrow;
    }
  };
}
