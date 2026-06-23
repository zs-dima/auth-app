import 'dart:math' as math;

import 'package:auth_app/_core/api/http/api_client.dart';
import 'package:auth_app/_core/api/http/middlewares/timeout_middleware.dart';
import 'package:meta/meta.dart';

/// HTTP methods that are safe to retry automatically (RFC 9110 §9.2.2).
const _kIdempotentMethods = <String>{'GET', 'HEAD', 'PUT', 'DELETE', 'OPTIONS', 'TRACE'};

/// Upper bound applied to a server-provided `Retry-After` delay.
const _kMaxRetryAfter = Duration(seconds: 60);

/// Parses a delta-seconds `Retry-After` from a 429/503 [ApiClientException$Network]
/// (capped at [_kMaxRetryAfter]). Returns `null` when absent or not delta-seconds.
Duration? _retryAfter(Object error) {
  if (error is! ApiClientException$Network) return null;
  if (error.data case <String, Object?>{'retry-after': final String ra}) {
    final seconds = int.tryParse(ra.trim());
    if (seconds != null && seconds >= 0) {
      final d = Duration(seconds: seconds);
      return d > _kMaxRetryAfter ? _kMaxRetryAfter : d;
    }
  }
  return null;
}

/// {@template retry_middleware}
/// Retries failed requests with exponential backoff (honoring `Retry-After`), for
/// idempotent methods only. Error classification is delegated to a single policy —
/// [retryEvaluator] or [defaultRetryEvaluator].
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

  /// Overrides [defaultRetryEvaluator] for deciding whether an error is retryable.
  final bool Function(Object error, int attempt)? retryEvaluator;

  /// Exponential backoff factor for retry delays.
  final List<Duration> retryDelays;

  /// The single source of truth for whether [error] is worth retrying — transient
  /// failures only. Used when [retryEvaluator] is not provided; callers that pass a
  /// custom evaluator replace this entirely (and should not re-implement it).
  ///
  /// `$Cancelled`/`$Timeout` are handled as a mechanic in [call] (their abort token is
  /// already completed, so a retry would abort instantly) and are intentionally absent here.
  static bool defaultRetryEvaluator(Object error, int attempt) => switch (error) {
    ApiClientException$Authentication() => false, // owned by TokenRefreshMiddleware
    // Transient/network failures only — never non-transient 4xx (400/404/409/422/…).
    ApiClientException$Network(:final statusCode) =>
      const <int>{0, 408, 425, 429, 500, 502, 503, 504, 509}.contains(statusCode),
    _ => false, // unknown errors: do not retry
  };

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    final retries = math.min(
      switch (context['retries']) {
        final int r when r >= 0 => r, // Use specified retries from context if non-negative
        _ => this.retries, // Use default retries
      },
      retryDelays.length, // Ensure retries do not exceed the number of delays
    );
    // Ignore retry logic if 'no-retry' or 'sse' is true, or if retries are 0

    // Only auto-retry idempotent methods — repeating a POST/PATCH whose response was lost
    // could duplicate a side effect. Non-idempotent endpoints opt in explicitly (e.g. when
    // they carry an idempotency key).
    final idempotent =
        _kIdempotentMethods.contains(request.method.toUpperCase()) ||
        context[kRetryNonIdempotentContextKey] == true;

    final shouldNotRetry =
        context[kNoRetryContextKey] == true ||
        context['sse'] == true ||
        retries < 1 ||
        retryDelays.isEmpty ||
        !idempotent;
    if (shouldNotRetry) return innerHandler(request, context);
    // Single source of truth for error classification (default unless overridden).
    final evaluate = retryEvaluator ?? defaultRetryEvaluator;
    var attempt = 0;
    var clonedRequest = request;
    // Retry loop while (attempt < retries)
    while (true) {
      try {
        return await innerHandler(clonedRequest, context);
      } catch (e) {
        // Mechanic (not policy): a cancelled/timed-out request already completed its abort
        // token, so a retry would reuse a finished abortTrigger and abort instantly.
        final mechanicForbidsRetry = e is ApiClientException$Cancelled || e is ApiClientException$Timeout;
        if (mechanicForbidsRetry || attempt >= retries || !evaluate(e, attempt)) {
          rethrow; // mechanic forbids, last attempt, or policy says no
        }
        // Honor the server's Retry-After (429/503) when present; otherwise exponential backoff.
        final delay = _retryAfter(e) ?? retryDelays[math.min(attempt, retryDelays.length - 1)];
        await Future<void>.delayed(delay);
        attempt++;
        clonedRequest = clonedRequest.clone(); // Clone the request for the next attempt
      }
    }
  };
}
