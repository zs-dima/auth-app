import 'dart:async';
import 'dart:math' as math;

import 'package:grpc/grpc.dart';
import 'package:grpc_model/src/middleware/grpc_middleware.dart';
import 'package:meta/meta.dart';

/// Callback to evaluate whether a request should be retried.
///
/// [error] is the error that occurred.
/// [attempt] is the current attempt number (0-indexed).
/// Returns true if the request should be retried.
typedef RetryEvaluator = bool Function(Object error, int attempt);

/// {@template grpc_retry_middleware}
/// Middleware for automatic retry of failed gRPC requests.
///
/// Implements exponential backoff and configurable retry logic.
/// {@endtemplate}
@immutable
class GrpcRetryMiddleware extends GrpcMiddlewareBase {
  /// {@macro grpc_retry_middleware}
  GrpcRetryMiddleware({
    this.retries = 3,
    this.retryEvaluator,
    this.retryDelays = const [Duration(seconds: 1), Duration(seconds: 2), Duration(seconds: 4)],
  }) : assert(retries >= 0, 'Retries must be non-negative'),
       assert(retryDelays.isNotEmpty && retryDelays.every((d) => d > Duration.zero), 'Retry delays must be positive'),
       assert(retryDelays.length >= retries, 'Retry delays must be at least as many as retries');

  /// Maximum number of retry attempts.
  final int retries;

  /// Custom evaluator to determine if a request should be retried.
  ///
  /// If null, uses [defaultRetryEvaluator].
  final RetryEvaluator? retryEvaluator;

  /// Delays between retry attempts.
  final List<Duration> retryDelays;

  /// Default retry evaluator that determines which errors are retryable.
  static bool defaultRetryEvaluator(Object error, int attempt) {
    // Don't retry authentication errors
    if (error is GrpcClientException$Authentication) return false;
    if (error is GrpcError && error.code == StatusCode.unauthenticated) return false;
    if (error is GrpcError && error.code == StatusCode.permissionDenied) return false;

    // Retry on timeout
    if (error is TimeoutException || error is GrpcClientException$Timeout) return true;

    // Retry on specific gRPC errors
    if (error is GrpcError) {
      return const {
        StatusCode.unavailable,
        StatusCode.resourceExhausted,
        StatusCode.aborted,
        StatusCode.internal,
        StatusCode.deadlineExceeded,
      }.contains(error.code);
    }

    if (error is GrpcClientException) {
      final statusCode = error.statusCode;
      if (statusCode == null) return true;
      return const {
        StatusCode.unavailable,
        StatusCode.resourceExhausted,
        StatusCode.aborted,
        StatusCode.internal,
        StatusCode.deadlineExceeded,
      }.contains(statusCode);
    }

    return true;
  }

  @override
  GrpcHandler<Q, R> call<Q, R>(GrpcHandler<Q, R> next) => (request, context) async {
    final noRetry = context['no-retry'] == true;
    final maxRetries = math.min(
      switch (context['retries']) {
        final int r when r >= 0 => r,
        _ => retries,
      },
      retryDelays.length,
    );

    if (noRetry || maxRetries < 1 || retryDelays.isEmpty) {
      return next(request, context);
    }

    var attempt = 0;
    while (true) {
      try {
        return await next(request, context);
      } on Object catch (e) {
        final shouldRetry = retryEvaluator?.call(e, attempt) ?? defaultRetryEvaluator(e, attempt);
        if (attempt >= maxRetries || !shouldRetry) rethrow;

        // Wait before retrying with exponential backoff
        await Future<void>.delayed(retryDelays[math.min(attempt, retryDelays.length - 1)]);
        attempt++;
      }
    }
  };
}
