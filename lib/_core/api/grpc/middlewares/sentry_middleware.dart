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
  ApiClientHandler call(ApiClientHandler invoker) => (path, metadata) async {
    final operation = /*context['operation']?.toString() ??*/ path;
    final transaction = // TODO:
        ( /*$currentSentryTransaction?.startChild(
                'grpc.client',
                description: operation,
                startTimestamp: DateTime.now().toUtc(),
              ) ??*/ Sentry.startTransaction(
            'grpc.client',
            operation,
            description: operation,
            bindToScope: true,
            startTimestamp: DateTime.now().toUtc(),
          ))
          // ..setData('grpc-request.method', request.method)
          // ..setData('url', request.url.toString())
          // ..setData('method', request.method)
          ..setData('path', path)
          // ..setData('query', request.url.queryParameters)
          ..setData('request_headers', metadata);

    // context['sentry.transaction'] = transaction;

    try {
      await invoker(path, metadata);
      transaction.setData('grpc.response.status_code', 200);
      if (!transaction.finished) transaction.finish(status: const SpanStatus.ok()).ignore();
    } on Object catch (e, s) {
      await Sentry.captureException(
        e,
        stackTrace: s,
        withScope: (scope) => scope.span = transaction,
        hint: Hint.withMap({
          // 'method': request.method,
          // 'url': request.url,
          'path': path,
          // 'query': request.url.queryParameters,
          'headers': metadata,
        }),
      );

      if (!transaction.finished) {
        transaction
            .finish(
              status: switch (e) {
                GrpcError(:final code) when code == StatusCode.unavailable => const SpanStatus.unavailable(),
                GrpcError(:final code) when code == StatusCode.unimplemented => const SpanStatus.unimplemented(),
                GrpcError(:final code) when code == StatusCode.internal => const SpanStatus.internalError(),
                GrpcError(:final code) when code == StatusCode.resourceExhausted =>
                  const SpanStatus.resourceExhausted(),
                GrpcError(:final code) when code == StatusCode.aborted => const SpanStatus.aborted(),
                GrpcError(:final code) when code == StatusCode.notFound => const SpanStatus.notFound(),
                GrpcError(:final code) when code == StatusCode.permissionDenied => const SpanStatus.permissionDenied(),
                GrpcError(:final code) when code == StatusCode.unauthenticated => const SpanStatus.unauthenticated(),
                GrpcError(:final code) when code == StatusCode.failedPrecondition =>
                  const SpanStatus.failedPrecondition(),
                GrpcError(:final code) when code == StatusCode.ok => const SpanStatus.ok(),
                _ => const SpanStatus.unknownError(),
              },
              endTimestamp: DateTime.now().toUtc(),
            )
            .ignore();
      }
      rethrow;
    }
  };
}
