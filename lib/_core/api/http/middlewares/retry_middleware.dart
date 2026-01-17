import 'dart:math' as math;

import 'package:auth_app/_core/api/http/api_client.dart';
import 'package:meta/meta.dart';

/// {@template retry_middleware}
/// Throws an exception if the request takes longer than the specified duration.
/// [RetryMiddleware] middleware is useful for preventing requests from hanging indefinitely.
/// {@endtemplate}
@immutable
class RetryMiddleware {
  /// {@macro retry_middleware}
  RetryMiddleware({
    this.retries = 3,
    this.retryEvaluator,
    this.retryDelays = const [Duration(seconds: 1), Duration(seconds: 2), Duration(seconds: 4)],
  }) : assert(retries >= 0, 'Retries must be non-negative'),
       assert(retryDelays.isNotEmpty && retryDelays.every((d) => d > .zero), 'Retry delays must not be empty'),
       assert(retryDelays.length >= retries, 'Retry delays must be at least as many as retries');

  /// Number of retries for the request.
  final int retries;

  /// Check if the request should be retried based on the error and attempt number.
  final bool Function(Object error, int attempt)? retryEvaluator;

  /// Exponential backoff factor for retry delays.
  final List<Duration> retryDelays;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    final retries = math.min(
      switch (context['retries']) {
        final int r when r >= 0 => r, // Use specified retries from context if non-negative
        _ => this.retries, // Use default retries
      },
      retryDelays.length, // Ensure retries do not exceed the number of delays
    );
    // Ignore retry logic if 'no-retry' or 'sse' is true, or if retries are 0

    final shouldNotRetry = context['no-retry'] == true || context['sse'] == true || retries < 1 || retryDelays.isEmpty;
    if (shouldNotRetry) return innerHandler(request, context);
    var attempt = 0;
    var clonedRequest = request;
    // Retry loop while (attempt < retries)
    while (true) {
      try {
        return await innerHandler(clonedRequest, context);
      } catch (e) {
        if (attempt >= retries || !(retryEvaluator?.call(e, attempt) ?? true)) {
          rethrow; // If last attempt or retryEvaluator says no, rethrow the error
        }
        // Wait for the specified delay before retrying
        final delay = retryDelays[math.min(attempt, retryDelays.length - 1)];
        await Future<void>.delayed(delay);
        attempt++;
        clonedRequest = clonedRequest.clone(); // Clone the request for the next attempt
      }
    }
  };
}
