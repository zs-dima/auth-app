// ignore_for_file: prefer-async-callback

import 'dart:async';
import 'dart:math' as math;

import 'package:core_model/core_model.dart';
import 'package:grpc/grpc.dart';
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

  /// Overrides [_defaultRetryEvaluator] for deciding whether an error is retryable.
  final bool Function(Object error, int attempt)? retryEvaluator;

  final math.Random _random;

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) => _RetryResponseFuture(_executeWithRetry(() => invoker(method, request, options)));

  Future<R> _executeWithRetry<R>(ResponseFuture<R> Function() invoke) async {
    var attempt = 0;
    final stopwatch = Stopwatch()..start();
    while (true) {
      try {
        return await invoke();
      } on Object catch (e) {
        final pushback = _pushback(e); // server-directed delay, or null
        final shouldRetry = retryEvaluator?.call(e, attempt) ?? _defaultRetryEvaluator(e, pushback);
        if (attempt >= backoff.maxRetries || !shouldRetry) rethrow;

        // Server pushback is authoritative (no jitter); otherwise full-jitter backoff.
        final delay = pushback ?? backoff.backoff(attempt, _random);
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

  /// Retries transient codes only. `RESOURCE_EXHAUSTED` is retried **only** when the server
  /// sent a (non-negative) pushback telling us it's safe; a negative pushback forbids any retry.
  static bool _defaultRetryEvaluator(Object error, Duration? pushback) {
    if (_pushbackForbidsRetry(error)) return false;
    return switch (error) {
      GrpcError(code: StatusCode.resourceExhausted) => pushback != null,
      GrpcError(:final code) => const {
        StatusCode.unavailable,
        StatusCode.aborted,
        StatusCode.internal,
        StatusCode.deadlineExceeded,
      }.contains(code),
      _ => false,
    };
  }
}

/// ResponseFuture wrapper for retry logic.
class _RetryResponseFuture<R> implements ResponseFuture<R> {
  const _RetryResponseFuture(this._future);
  final Future<R> _future;

  @override
  Future<Map<String, String>> get headers async => {};
  @override
  Future<Map<String, String>> get trailers async => {};
  @override
  Future<void> cancel() async {}
  @override
  Stream<R> asStream() => _future.asStream();
  @override
  // ignore: prefer-explicit-function-type
  Future<R> catchError(Function onError, {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);
  @override
  // ignore: prefer-explicit-function-type
  Future<S> then<S>(FutureOr<S> Function(R value) onValue, {Function? onError}) =>
      _future.then(onValue, onError: onError);
  @override
  Future<R> timeout(Duration timeLimit, {FutureOr<R> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);
  @override
  Future<R> whenComplete(FutureOr<void> Function() action) => _future.whenComplete(action);
}
