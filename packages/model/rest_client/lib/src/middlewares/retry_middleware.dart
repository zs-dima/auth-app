// ignore_for_file: prefer-async-callback
import 'dart:math' as math;

import 'package:core_model/core_model.dart';
import 'package:meta/meta.dart';
import 'package:rest_client/src/api_client.dart';
import 'package:rest_client/src/middlewares/timeout_middleware.dart';

/// HTTP methods that are safe to retry automatically (RFC 9110 §9.2.2).
const _kIdempotentMethods = <String>{'GET', 'HEAD', 'PUT', 'DELETE', 'OPTIONS', 'TRACE'};

/// Upper bound applied to a server-provided `Retry-After` delay (server is authoritative;
/// the total [RetryBackoff.maxElapsed] budget is the real ceiling).
const _kMaxRetryAfter = Duration(seconds: 60);

/// Parses a delta-seconds `Retry-After` from a 429/503 [ApiClientException] (429 → `$Request`,
/// 503 → `$Server`) (capped at [_kMaxRetryAfter]). Returns `null` when absent or not delta-seconds.
///
/// The HTTP-date form (RFC 9110 §10.2.3) is intentionally NOT parsed: it is rare in practice, and
/// when present the caller falls back to bounded full-jitter backoff — safe, just not honoring the
/// exact date. This avoids a date-parsing dependency for a near-unused path.
Duration? _retryAfter(Object error) {
  if (error is! ApiClientException) return null;
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
///
/// Consistency note (vs gRPC `GrpcRetryMiddleware`): HTTP gates on method idempotency (RFC 9110)
/// and does **not** retry `$Timeout` (its abort token is already consumed). gRPC has no verb
/// semantics (retries any unary on transient codes) and retries `DEADLINE_EXCEEDED` with a fresh
/// deadline per attempt. Both are intentional, transport-appropriate differences.
/// {@endtemplate}
@immutable
class RetryMiddleware {
  /// {@macro retry_middleware}
  RetryMiddleware({this.backoff = const RetryBackoff(), this.retryEvaluator, math.Random? random})
    : _random = random ?? math.Random();

  /// Jitter source; injectable for deterministic tests.
  final math.Random _random;

  /// Backoff policy: max retries, full-jitter exponential delays, per-attempt ceiling, total budget.
  final RetryBackoff backoff;

  /// Overrides [defaultRetryEvaluator] for deciding whether an error is retryable.
  final bool Function(Object error, int attempt)? retryEvaluator;

  /// The single source of truth for whether [error] is worth retrying — transient
  /// failures only. Used when [retryEvaluator] is not provided; callers that pass a
  /// custom evaluator replace this entirely (and should not re-implement it).
  ///
  /// `$Cancelled`/`$Timeout` are handled as a mechanic in [call] (their abort token is
  /// already completed, so a retry would abort instantly) and are intentionally absent here.
  static bool defaultRetryEvaluator(Object error, int attempt) => switch (error) {
    ApiClientException$Authentication() => false, // owned by AuthenticationMiddleware (401 refresh)
    // $Cancelled/$Timeout: their abort token is already completed, so a retry would abort instantly.
    // Also enforced as a mechanic in [call]; matched here too so the evaluator is correct in isolation.
    ApiClientException$Cancelled() || ApiClientException$Timeout() => false,
    // Transient failures only, keyed on the status code across every subtype ($Network=0, $Server
    // 5xx, $Request 408/425/429) — never a non-transient 4xx (400/404/409/422/…).
    ApiClientException(:final statusCode) => const <int>{
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
    // Only auto-retry idempotent methods — repeating a POST/PATCH whose response was lost
    // could duplicate a side effect. Non-idempotent endpoints opt in explicitly (e.g. when
    // they carry an idempotency key).
    final idempotent =
        _kIdempotentMethods.contains(request.method.toUpperCase()) || context[kRetryNonIdempotentContextKey] == true;

    final shouldNotRetry =
        context[kNoRetryContextKey] == true ||
        context[kSseContextKey] == true ||
        backoff.maxRetries < 1 ||
        !idempotent ||
        !request.canBeRetried; // multipart/streamed bodies can't be replayed via clone()
    if (shouldNotRetry) return innerHandler(request, context);
    // Single source of truth for error classification (default unless overridden).
    final evaluate = retryEvaluator ?? defaultRetryEvaluator;
    var attempt = 0;
    var clonedRequest = request;
    final stopwatch = Stopwatch()..start();
    // Retry loop while (attempt < backoff.maxRetries)
    while (true) {
      try {
        return await innerHandler(clonedRequest, context);
      } catch (e) {
        // Mechanic (not policy): a cancelled/timed-out request already completed its abort
        // token, so a retry would reuse a finished abortTrigger and abort instantly.
        final mechanicForbidsRetry = e is ApiClientException$Cancelled || e is ApiClientException$Timeout;
        if (mechanicForbidsRetry || attempt >= backoff.maxRetries || !evaluate(e, attempt)) {
          rethrow; // mechanic forbids, last attempt, or policy says no
        }
        // Honor the server's Retry-After (429/503) verbatim; otherwise full-jitter backoff.
        final delay = _retryAfter(e) ?? backoff.backoff(attempt, _random);
        // Total-time budget: give up rather than wait past it.
        if (!backoff.withinBudget(stopwatch.elapsed, delay)) rethrow;
        await Future<void>.delayed(delay);
        attempt++;
        clonedRequest = clonedRequest.clone(); // Clone the request for the next attempt
      }
    }
  };
}
