// ignore_for_file: prefer-async-callback

import 'dart:async';
import 'dart:math' as math;

import 'package:connect_model/src/middleware/connect_middleware.dart';
import 'package:connectrpc/connect.dart';
import 'package:core_model/core_model.dart';
import 'package:meta/meta.dart';

/// Trailing-metadata key by which the server tells the client how long to wait before retrying.
/// A negative value means "do not retry" (per the gRPC retry design, which Connect inherits).
const _kRetryPushbackHeader = 'grpc-retry-pushback-ms';

/// Over the Connect protocol, unary trailing metadata is demoted to `trailer-`-prefixed response
/// headers; depending on the transport path the pushback may surface under either key, so both
/// are read (pinned by the pushback-key test).
const _kRetryPushbackTrailerHeader = 'trailer-$_kRetryPushbackHeader';

/// Upper bound applied to a server pushback delay (the total budget is the real ceiling).
const _kMaxPushback = Duration(seconds: 60);

/// {@template connect_retry_middleware}
/// The **sole** transient-retry layer for the Connect transport: retries transient unary calls
/// with full-jitter exponential backoff ([RetryBackoff]), honoring server pushback
/// (`grpc-retry-pushback-ms`) and a total time budget. Do NOT add retries elsewhere
/// (repositories, use-cases) — nested retries amplify.
///
/// Only unary requests are retried; streaming RPCs are not replayable and pass through untouched
/// (matches HTTP `RetryMiddleware`, which only retries replayable bodies).
///
/// Consistency note (vs HTTP `RetryMiddleware`): RPC has no verb semantics, so retry is purely
/// codes-based (any unary call). `DEADLINE_EXCEEDED` is retried, but note the deadline model
/// changed with Connect: the per-call `TimeoutSignal` bounds the whole logical call INCLUDING
/// retries (grpc-dart re-armed the deadline per attempt), so a deadline-exceeded retry only helps
/// under a custom, longer timeout budget — rebuild the request with a fresh signal per attempt
/// here if per-attempt deadlines are ever wanted. `UNAVAILABLE` is process-safe; a non-idempotent
/// RPC sensitive to `INTERNAL`/`ABORTED` retries should opt out via a custom [retryEvaluator].
/// Intentional, transport-appropriate. `UNAUTHENTICATED` is excluded — recovered by the auth
/// middleware's reactive refresh.
///
/// Implemented against the raw connect-dart [Interceptor] contract (not `ConnectMiddleware`) —
/// the retry loop needs the typed request/response flow, not the (path, metadata) handler (A13).
/// {@endtemplate}
@immutable
class ConnectRetryMiddleware {
  /// {@macro connect_retry_middleware}
  ConnectRetryMiddleware({
    this.backoff = const RetryBackoff(),
    this.retryEvaluator,
    this.noRetryPaths = const <String>{},
    math.Random? random,
  }) : _random = random ?? math.Random();

  /// Backoff policy: max retries, full-jitter exponential delays, per-attempt ceiling, total budget.
  final RetryBackoff backoff;

  /// Paths (canonical `/package.Service/Method`) that must never be replayed (e.g. `RefreshTokens`
  /// — a replay trips reuse detection). Single attempt; [retryEvaluator] is not consulted.
  final Set<String> noRetryPaths;

  /// Overrides [defaultRetryEvaluator] for deciding whether an error is retryable. A server
  /// "do-not-retry" (negative `grpc-retry-pushback-ms`) and caller cancellation are enforced as
  /// mechanics in [_executeWithRetry] — they hold regardless of a custom evaluator.
  final bool Function(Object error, int attempt)? retryEvaluator;

  final math.Random _random;

  /// connect-dart [Interceptor] entry point (callable class).
  AnyFn<I, O> call<I extends Object, O extends Object>(AnyFn<I, O> next) => (req) {
    if (req is! UnaryRequest<I, O>) return next(req); // streaming RPCs pass through untouched
    // Opted-out path: single attempt, no retry wrapper at all.
    if (noRetryPaths.contains(ConnectMiddleware.normalizePath(req.spec.procedure))) return next(req);
    return _executeWithRetry(req, next);
  };

  Future<Response<I, O>> _executeWithRetry<I extends Object, O extends Object>(
    UnaryRequest<I, O> req,
    AnyFn<I, O> next,
  ) async {
    final evaluate = retryEvaluator ?? defaultRetryEvaluator; // single source of truth
    // Signals expose aborts as a future (no sync flag) — track locally so the loop can stop
    // between attempts (covers cancellation during a backoff delay; the in-flight attempt itself
    // is aborted by the transport racing the request signal).
    var aborted = false;
    req.signal.future.then((_) => aborted = true).ignore();
    var attempt = 0;
    final stopwatch = Stopwatch()..start();
    while (true) {
      if (aborted) throw ConnectException(.canceled, 'Call canceled by caller');
      try {
        return await next(req);
      } on Object catch (e) {
        // Mechanics (not policy): caller cancellation and a server "do-not-retry" (negative
        // pushback) are honored regardless of `evaluate` — mirrors HTTP's $Cancelled/$Timeout.
        if (aborted || _pushbackForbidsRetry(e) || attempt >= backoff.maxRetries || !evaluate(e, attempt)) {
          rethrow;
        }
        // Server pushback is authoritative (no jitter); otherwise full-jitter backoff.
        final delay = _pushback(e) ?? backoff.backoff(attempt, _random);
        if (!backoff.withinBudget(stopwatch.elapsed, delay)) rethrow; // total budget
        await Future<void>.delayed(delay);
        attempt++;
      }
    }
  }

  /// Raw pushback value from a [ConnectException]'s metadata (headers + trailers union), read
  /// under both the plain and the `trailer-`-prefixed key.
  static String? _rawPushback(Object error) {
    if (error is! ConnectException) return null;
    return error.metadata[_kRetryPushbackHeader] ?? error.metadata[_kRetryPushbackTrailerHeader];
  }

  /// Parses the pushback into a non-negative [Duration] to wait (capped at [_kMaxPushback]), or
  /// `null` when absent/negative — a negative value is surfaced via [_pushbackForbidsRetry].
  static Duration? _pushback(Object error) {
    final raw = _rawPushback(error);
    final ms = raw == null ? null : int.tryParse(raw.trim());
    if (ms == null || ms < 0) return null;
    final d = Duration(milliseconds: ms);
    return d > _kMaxPushback ? _kMaxPushback : d;
  }

  /// `true` when the server explicitly told us NOT to retry (negative pushback).
  static bool _pushbackForbidsRetry(Object error) {
    final raw = _rawPushback(error);
    final ms = raw == null ? null : int.tryParse(raw.trim());
    return ms != null && ms < 0;
  }

  /// The single source of truth for whether [error] is worth retrying — transient RPC codes
  /// only. `RESOURCE_EXHAUSTED` is retried **only** when the server sent a (non-negative)
  /// pushback telling us it's safe. A negative pushback ("do not retry") is enforced as a
  /// mechanic in [_executeWithRetry], so it is not re-checked here.
  ///
  /// Public + `(error, attempt)` to mirror `RetryMiddleware.defaultRetryEvaluator`; callers that
  /// pass a custom [retryEvaluator] replace this entirely (and should not re-implement it).
  static bool defaultRetryEvaluator(Object error, int attempt) => switch (error) {
    ConnectException(code: Code.resourceExhausted) => _pushback(error) != null,
    ConnectException(:final code) => const {
      Code.unavailable,
      Code.aborted,
      Code.internal,
      Code.deadlineExceeded,
    }.contains(code),
    _ => false,
  };
}
