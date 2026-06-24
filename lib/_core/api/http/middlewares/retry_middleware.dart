// ignore_for_file: prefer-async-callback
import 'dart:math' as math;

import 'package:auth_app/_core/api/http/api_client.dart';
import 'package:auth_app/_core/api/http/middlewares/timeout_middleware.dart';
import 'package:core_model/core_model.dart';
import 'package:meta/meta.dart';

/// HTTP methods that are safe to retry automatically (RFC 9110 §9.2.2).
const _kIdempotentMethods = <String>{'GET', 'HEAD', 'PUT', 'DELETE', 'OPTIONS', 'TRACE'};

/// Upper bound applied to a server-provided `Retry-After` delay (server is authoritative;
/// the total [RetryBackoff.maxElapsed] budget is the real ceiling).
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
/// The **sole** transient-retry layer for the HTTP transport: retries idempotent requests
/// with full-jitter exponential backoff ([RetryBackoff]), honoring `Retry-After` and a total
/// time budget. Do NOT add retries elsewhere (repositories/use-cases) — nested retries amplify.
///
/// Error classification is delegated to a single policy — [retryEvaluator] or
/// [defaultRetryEvaluator].
/// {@endtemplate}
@immutable
class RetryMiddleware {
  /// {@macro retry_middleware}
  RetryMiddleware({
    this.backoff = const RetryBackoff(),
    this.retryEvaluator,
    this.awaitConnectivity,
    math.Random? random,
  }) : _random = random ?? math.Random();

  /// Jitter source; injectable for deterministic tests.
  final math.Random _random;

  /// Backoff policy: max retries, full-jitter exponential delays, per-attempt ceiling, total budget.
  final RetryBackoff backoff;

  /// Overrides [defaultRetryEvaluator] for deciding whether an error is retryable.
  final bool Function(Object error, int attempt)? retryEvaluator;

  /// Optional connectivity gate: awaited (bounded by the remaining budget) before each retry so
  /// time spent offline on a mobile network doesn't burn retry attempts. Injected by the app so
  /// this layer stays Flutter-free; a `null` value means "retry immediately".
  final Future<void> Function()? awaitConnectivity;

  /// The single source of truth for whether [error] is worth retrying — transient
  /// failures only. Used when [retryEvaluator] is not provided; callers that pass a
  /// custom evaluator replace this entirely (and should not re-implement it).
  ///
  /// `$Cancelled`/`$Timeout` are handled as a mechanic in [call] (their abort token is
  /// already completed, so a retry would abort instantly) and are intentionally absent here.
  static bool defaultRetryEvaluator(Object error, int attempt) => switch (error) {
    ApiClientException$Authentication() => false, // owned by TokenRefreshMiddleware
    // Transient/network failures only — never non-transient 4xx (400/404/409/422/…).
    ApiClientException$Network(:final statusCode) => const <int>{
      0,
      408,
      425,
      429,
      500,
      502,
      503,
      504,
      509,
    }.contains(statusCode),
    _ => false, // unknown errors: do not retry
  };

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    final maxRetries = switch (context['retries']) {
      final int r when r >= 0 => r, // per-request override
      _ => backoff.maxRetries,
    };

    // Only auto-retry idempotent methods — repeating a POST/PATCH whose response was lost
    // could duplicate a side effect. Non-idempotent endpoints opt in explicitly (e.g. when
    // they carry an idempotency key).
    final idempotent =
        _kIdempotentMethods.contains(request.method.toUpperCase()) || context[kRetryNonIdempotentContextKey] == true;

    final shouldNotRetry =
        context[kNoRetryContextKey] == true ||
        context['sse'] == true ||
        maxRetries < 1 ||
        !idempotent ||
        !request.canBeRetried; // multipart/streamed bodies can't be replayed via clone()
    if (shouldNotRetry) return innerHandler(request, context);
    // Single source of truth for error classification (default unless overridden).
    final evaluate = retryEvaluator ?? defaultRetryEvaluator;
    var attempt = 0;
    var clonedRequest = request;
    final stopwatch = Stopwatch()..start();
    // Retry loop while (attempt < maxRetries)
    while (true) {
      try {
        return await innerHandler(clonedRequest, context);
      } catch (e) {
        // Mechanic (not policy): a cancelled/timed-out request already completed its abort
        // token, so a retry would reuse a finished abortTrigger and abort instantly.
        final mechanicForbidsRetry = e is ApiClientException$Cancelled || e is ApiClientException$Timeout;
        if (mechanicForbidsRetry || attempt >= maxRetries || !evaluate(e, attempt)) {
          rethrow; // mechanic forbids, last attempt, or policy says no
        }
        // Honor the server's Retry-After (429/503) verbatim; otherwise full-jitter backoff.
        final delay = _retryAfter(e) ?? backoff.backoff(attempt, _random);
        // Total-time budget: give up rather than wait past it.
        if (!backoff.withinBudget(stopwatch.elapsed, delay)) rethrow;
        // Connectivity-aware: wait (bounded by the remaining budget) for the network instead of
        // burning this attempt while offline. If it never returns in time, give up.
        final connectivity = awaitConnectivity;
        if (connectivity != null) {
          final remaining = backoff.maxElapsed - stopwatch.elapsed;
          if (remaining <= .zero) rethrow;
          var online = true;
          await connectivity().timeout(remaining, onTimeout: () => online = false);
          if (!online) rethrow;
        }
        await Future<void>.delayed(delay);
        attempt++;
        clonedRequest = clonedRequest.clone(); // Clone the request for the next attempt
      }
    }
  };
}
