// ignore_for_file: prefer-async-callback

import 'dart:async';
import 'dart:math' as math;

import 'package:grpc/grpc.dart';
import 'package:meta/meta.dart';

/// {@template grpc_retry_middleware}
/// Middleware for automatic retry of failed gRPC requests.
/// {@endtemplate}
@immutable
class GrpcRetryMiddleware extends ClientInterceptor {
  /// {@macro grpc_retry_middleware}
  GrpcRetryMiddleware({
    this.retries = 3,
    this.retryEvaluator,
    this.retryDelays = const [Duration(seconds: 1), Duration(seconds: 2), Duration(seconds: 4)],
  }) : assert(retries >= 0, 'Retries must be non-negative'),
       assert(retryDelays.isNotEmpty, 'Retry delays must not be empty');

  final int retries;
  final bool Function(Object error, int attempt)? retryEvaluator;
  final List<Duration> retryDelays;

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) => _RetryResponseFuture(_executeWithRetry(() => invoker(method, request, options)));

  Future<R> _executeWithRetry<R>(ResponseFuture<R> Function() invoke) async {
    var attempt = 0;
    while (true) {
      try {
        return await invoke();
      } on Object catch (e) {
        final shouldRetry = retryEvaluator?.call(e, attempt) ?? _defaultRetryEvaluator(e);
        if (attempt >= retries || !shouldRetry) rethrow;
        // Exponential backoff delay before retrying
        await Future<void>.delayed(retryDelays[math.min(attempt, retryDelays.length - 1)]);
        attempt++;
      }
    }
  }

  static bool _defaultRetryEvaluator(Object error) => switch (error) {
    GrpcError(:final code) => const {
      StatusCode.unavailable,
      StatusCode.resourceExhausted,
      StatusCode.aborted,
      StatusCode.internal,
      StatusCode.deadlineExceeded,
    }.contains(code),
    _ => false,
  };
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
