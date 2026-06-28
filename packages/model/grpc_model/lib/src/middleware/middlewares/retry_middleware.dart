// ignore_for_file: prefer-async-callback

import 'dart:math' as math;

import 'package:core_model/core_model.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_model/src/middleware/response_future_holder.dart';
import 'package:meta/meta.dart';

/// Trailing-metadata key by which a gRPC server tells the client how long to wait before
/// retrying. A negative value means "do not retry" (per the gRPC retry design).
const _kRetryPushbackHeader = 'grpc-retry-pushback-ms';

/// Upper bound applied to a server pushback delay (the total budget is the real ceiling).
const _kMaxPushback = Duration(seconds: 60);

/// {@template grpc_retry_middleware}
/// The **sole** transient-retry layer for the gRPC transport: retries transient unary calls
/// with full-jitter exponential backoff ([RetryBackoff]), honoring server pushback
/// (`grpc-retry-pushback-ms`) and a total time budget. Do NOT add retries elsewhere (channel
/// `retryPolicy`, repositories, use-cases) — nested retries amplify.
///
/// Only `interceptUnary` is retried; streaming RPCs are not replayable and pass through
/// untouched (matches HTTP `RetryMiddleware`, which only retries replayable bodies).
///
/// Consistency note (vs HTTP `RetryMiddleware`): gRPC has no verb semantics, so retry is purely
/// codes-based (any unary call) and `DEADLINE_EXCEEDED` is retried with a fresh deadline per
/// attempt. `UNAVAILABLE` is process-safe; a non-idempotent RPC sensitive to `INTERNAL`/`ABORTED`
/// retries should opt out via a custom [retryEvaluator]. Intentional, transport-appropriate.
/// {@endtemplate}
@immutable
class GrpcRetryMiddleware extends ClientInterceptor {
  /// {@macro grpc_retry_middleware}
  GrpcRetryMiddleware({this.backoff = const RetryBackoff(), this.retryEvaluator, math.Random? random})
    : _random = random ?? math.Random();

  /// Backoff policy: max retries, full-jitter exponential delays, per-attempt ceiling, total budget.
  final RetryBackoff backoff;

  /// Overrides [defaultRetryEvaluator] for deciding whether an error is retryable. A server
  /// "do-not-retry" (negative `grpc-retry-pushback-ms`) and caller cancellation are enforced as
  /// mechanics in [_executeWithRetry] — they hold regardless of a custom evaluator.
  final bool Function(Object error, int attempt)? retryEvaluator;

  final math.Random _random;

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final holder = _RetryHolder<R>();
    return HolderResponseFuture<R>(
      _executeWithRetry(() {
        final response = invoker(method, request, options);
        holder.response = response; // synchronous: set before the first await
        return response;
      }, holder),
      holder,
    );
  }

  Future<R> _executeWithRetry<R>(ResponseFuture<R> Function() invoke, _RetryHolder<R> holder) async {
    final evaluate = retryEvaluator ?? defaultRetryEvaluator; // single source of truth
    var attempt = 0;
    final stopwatch = Stopwatch()..start();
    while (true) {
      if (holder.cancelled) throw const GrpcError.cancelled('Call cancelled by caller');
      try {
        return await invoke();
      } on Object catch (e) {
        // Mechanics (not policy): caller cancellation and a server "do-not-retry" (negative
        // pushback) are honored regardless of `evaluate` — mirrors HTTP's $Cancelled/$Timeout.
        if (holder.cancelled || _pushbackForbidsRetry(e) || attempt >= backoff.maxRetries || !evaluate(e, attempt)) {
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

  /// Parses `grpc-retry-pushback-ms` from a [GrpcError]'s trailers. Returns a non-negative
  /// [Duration] to wait (capped at [_kMaxPushback]), or `null` when absent/negative — a
  /// negative value is surfaced via [_pushbackForbidsRetry].
  static Duration? _pushback(Object error) {
    if (error is! GrpcError) return null;
    final raw = error.trailers?[_kRetryPushbackHeader];
    final ms = raw == null ? null : int.tryParse(raw.trim());
    if (ms == null || ms < 0) return null;
    final d = Duration(milliseconds: ms);
    return d > _kMaxPushback ? _kMaxPushback : d;
  }

  /// `true` when the server explicitly told us NOT to retry (negative pushback).
  static bool _pushbackForbidsRetry(Object error) {
    if (error is! GrpcError) return false;
    final raw = error.trailers?[_kRetryPushbackHeader];
    final ms = raw == null ? null : int.tryParse(raw.trim());
    return ms != null && ms < 0;
  }

  /// The single source of truth for whether [error] is worth retrying — transient gRPC codes
  /// only. `RESOURCE_EXHAUSTED` is retried **only** when the server sent a (non-negative)
  /// pushback telling us it's safe. A negative pushback ("do not retry") is enforced as a
  /// mechanic in [_executeWithRetry], so it is not re-checked here.
  ///
  /// Public + `(error, attempt)` to mirror `RetryMiddleware.defaultRetryEvaluator`; callers that
  /// pass a custom [retryEvaluator] replace this entirely (and should not re-implement it).
  static bool defaultRetryEvaluator(Object error, int attempt) => switch (error) {
    GrpcError(code: StatusCode.resourceExhausted) => _pushback(error) != null,
    GrpcError(:final code) => const {
      StatusCode.unavailable,
      StatusCode.aborted,
      StatusCode.internal,
      StatusCode.deadlineExceeded,
    }.contains(code),
    _ => false,
  };
}

/// Holder for the retry loop's in-flight attempt. Adds [cancelled] (read by [_executeWithRetry] to
/// stop the loop, e.g. during a backoff delay) over the shared [ResponseFutureHolder], and overrides
/// [cancel] to set it before aborting the attempt. The deferred [ResponseFuture] wrapper itself is
/// the shared [HolderResponseFuture].
class _RetryHolder<R> extends ResponseFutureHolder<R> {
  bool cancelled = false;

  @override
  Future<void> cancel() async {
    cancelled = true; // stop the loop (covers cancellation during a backoff delay)
    await response?.cancel(); // abort the in-flight attempt
  }
}
