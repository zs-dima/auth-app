// ignore_for_file: prefer-explicit-function-type, prefer-const-constructor-declarations

import 'dart:async';
import 'dart:math' as math;

import 'package:core_model/core_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_model/grpc_model.dart';

/// Minimal [ResponseFuture] that just delegates to a plain [Future] — enough to
/// drive [GrpcRetryMiddleware.interceptUnary] without a real gRPC channel.
class _FakeResponseFuture<R> implements ResponseFuture<R> {
  const _FakeResponseFuture(
    this._future, {
    Map<String, String> headers = const <String, String>{},
    Map<String, String> trailers = const <String, String>{},
    this.onCancel,
  }) : _headers = headers,
       _trailers = trailers;
  final Future<R> _future;
  final void Function()? onCancel;
  final Map<String, String> _headers;
  final Map<String, String> _trailers;

  @override
  Future<Map<String, String>> get headers async => _headers;
  @override
  Future<Map<String, String>> get trailers async => _trailers;
  @override
  Future<void> cancel() async => onCancel?.call();
  @override
  Stream<R> asStream() => _future.asStream();
  @override
  Future<R> catchError(Function onError, {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);
  @override
  Future<S> then<S>(FutureOr<S> Function(R value) onValue, {Function? onError}) =>
      _future.then(onValue, onError: onError);
  @override
  Future<R> timeout(Duration timeLimit, {FutureOr<R> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);
  @override
  Future<R> whenComplete(FutureOr<void> Function() action) => _future.whenComplete(action);
}

final _method = ClientMethod<int, int>('/svc.v1.Service/Method', (q) => <int>[], (b) => 0);

GrpcError _withPushback(int code, int pushbackMs) =>
    GrpcError.custom(code, 'x', null, null, {'grpc-retry-pushback-ms': '$pushbackMs'});

void main() {
  GrpcRetryMiddleware middleware() => GrpcRetryMiddleware(
    backoff: const RetryBackoff(
      maxRetries: 2,
      baseDelay: Duration(milliseconds: 1),
      maxDelay: Duration(milliseconds: 1),
    ),
    random: math.Random(1),
  );

  group('GrpcRetryMiddleware', () {
    test('retries a transient GrpcError (unavailable) then succeeds', () async {
      var attempts = 0;
      final result = await middleware().interceptUnary<int, int>(_method, 1, CallOptions(), (m, req, opts) {
        attempts++;
        if (attempts == 1) return _FakeResponseFuture<int>(Future<int>.error(const GrpcError.unavailable('down')));
        return _FakeResponseFuture<int>(Future<int>.value(42));
      });

      expect(attempts, 2);
      expect(result, 42);
    });

    test('does not retry UNAUTHENTICATED (owned by the auth middleware)', () async {
      var attempts = 0;
      final Future<int> call = middleware().interceptUnary<int, int>(_method, 1, CallOptions(), (m, req, opts) {
        attempts++;
        return _FakeResponseFuture<int>(Future<int>.error(const GrpcError.unauthenticated('no')));
      });

      await expectLater(call, throwsA(isA<GrpcError>()));
      expect(attempts, 1);
    });

    test('does not retry a non-transient GrpcError (notFound)', () async {
      var attempts = 0;
      final Future<int> call = middleware().interceptUnary<int, int>(_method, 1, CallOptions(), (m, req, opts) {
        attempts++;
        return _FakeResponseFuture<int>(Future<int>.error(const GrpcError.notFound('missing')));
      });

      await expectLater(call, throwsA(isA<GrpcError>()));
      expect(attempts, 1);
    });

    test('does NOT retry RESOURCE_EXHAUSTED without server pushback', () async {
      var attempts = 0;
      final Future<int> call = middleware().interceptUnary<int, int>(_method, 1, CallOptions(), (m, req, opts) {
        attempts++;
        return _FakeResponseFuture<int>(Future<int>.error(const GrpcError.resourceExhausted('quota')));
      });

      await expectLater(call, throwsA(isA<GrpcError>()));
      expect(attempts, 1, reason: 'resourceExhausted is retried only when the server sends pushback');
    });

    test('retries RESOURCE_EXHAUSTED when the server sends a (non-negative) pushback', () async {
      var attempts = 0;
      final result = await middleware().interceptUnary<int, int>(_method, 1, CallOptions(), (m, req, opts) {
        attempts++;
        if (attempts == 1) return _FakeResponseFuture<int>(Future<int>.error(_withPushback(StatusCode.resourceExhausted, 1)));
        return _FakeResponseFuture<int>(Future<int>.value(7));
      });

      expect(attempts, 2);
      expect(result, 7);
    });

    test('negative pushback forbids retry even for an otherwise-transient code', () async {
      var attempts = 0;
      final Future<int> call = middleware().interceptUnary<int, int>(_method, 1, CallOptions(), (m, req, opts) {
        attempts++;
        return _FakeResponseFuture<int>(Future<int>.error(_withPushback(StatusCode.unavailable, -1)));
      });

      await expectLater(call, throwsA(isA<GrpcError>()));
      expect(attempts, 1, reason: 'a negative pushback means do not retry');
    });

    test('a custom retryEvaluator can retry an otherwise non-retryable code', () async {
      var attempts = 0;
      final mw = GrpcRetryMiddleware(
        backoff: const RetryBackoff(
          maxRetries: 2,
          baseDelay: Duration(milliseconds: 1),
          maxDelay: Duration(milliseconds: 1),
        ),
        random: math.Random(1),
        retryEvaluator: (error, attempt) => true, // force retry regardless of code
      );

      final result = await mw.interceptUnary<int, int>(_method, 1, CallOptions(), (m, req, opts) {
        attempts++;
        if (attempts == 1) return _FakeResponseFuture<int>(Future<int>.error(const GrpcError.notFound('x')));
        return _FakeResponseFuture<int>(Future<int>.value(9));
      });

      expect(attempts, 2);
      expect(result, 9);
    });

    test('a custom retryEvaluator cannot retry against a negative pushback (mechanic)', () async {
      var attempts = 0;
      final mw = GrpcRetryMiddleware(
        backoff: const RetryBackoff(
          maxRetries: 2,
          baseDelay: Duration(milliseconds: 1),
          maxDelay: Duration(milliseconds: 1),
        ),
        random: math.Random(1),
        retryEvaluator: (error, attempt) => true, // wants to retry, but the mechanic wins
      );

      final Future<int> call = mw.interceptUnary<int, int>(_method, 1, CallOptions(), (m, req, opts) {
        attempts++;
        return _FakeResponseFuture<int>(Future<int>.error(_withPushback(StatusCode.unavailable, -1)));
      });

      await expectLater(call, throwsA(isA<GrpcError>()));
      expect(attempts, 1, reason: 'negative pushback is a mechanic; a custom evaluator cannot override it');
    });
  });

  group('GrpcRetryMiddleware ResponseFuture contract', () {
    test('headers/trailers delegate to the final attempt', () async {
      final rf = middleware().interceptUnary<int, int>(
        _method,
        1,
        CallOptions(),
        (m, req, opts) => _FakeResponseFuture<int>(
          Future<int>.value(5),
          headers: const {'h': '1'},
          trailers: const {'t': '2'},
        ),
      );

      expect(await rf, 5);
      expect(await rf.headers, equals(const {'h': '1'}));
      expect(await rf.trailers, equals(const {'t': '2'}));
    });

    test('cancel() aborts the in-flight attempt and stops retrying', () async {
      var attempts = 0;
      var underlyingCancelled = false;
      final completer = Completer<int>();

      final rf = middleware().interceptUnary<int, int>(_method, 1, CallOptions(), (m, req, opts) {
        attempts++;
        return _FakeResponseFuture<int>(
          completer.future,
          onCancel: () {
            underlyingCancelled = true;
            if (!completer.isCompleted) {
              completer.completeError(const GrpcError.cancelled('cancelled'), StackTrace.current);
            }
          },
        );
      });

      // Start listening for the (intended) cancellation error BEFORE cancelling, so it always
      // has a handler — otherwise the call completing with CANCELLED briefly looks unhandled.
      final Future<int> call = rf; // ResponseFuture is a Future; type it so throwsA accepts it
      final expectation = expectLater(call, throwsA(isA<GrpcError>()));
      await rf.cancel();
      await expectation;

      expect(underlyingCancelled, isTrue, reason: 'cancel propagates to the in-flight ResponseFuture');
      expect(attempts, 1, reason: 'no further attempt after cancellation');
    });
  });

  group('GrpcRetryMiddleware.defaultRetryEvaluator', () {
    test('is public and classifies transient codes (mirrors HTTP)', () {
      expect(GrpcRetryMiddleware.defaultRetryEvaluator(const GrpcError.unavailable('x'), 0), isTrue);
      expect(GrpcRetryMiddleware.defaultRetryEvaluator(const GrpcError.deadlineExceeded('x'), 0), isTrue);
      expect(GrpcRetryMiddleware.defaultRetryEvaluator(const GrpcError.notFound('x'), 0), isFalse);
      expect(GrpcRetryMiddleware.defaultRetryEvaluator(const GrpcError.unauthenticated('x'), 0), isFalse);
      expect(
        GrpcRetryMiddleware.defaultRetryEvaluator(const GrpcError.resourceExhausted('x'), 0),
        isFalse,
        reason: 'no server pushback → not retried',
      );
      expect(
        GrpcRetryMiddleware.defaultRetryEvaluator(_withPushback(StatusCode.resourceExhausted, 5), 0),
        isTrue,
        reason: 'a (non-negative) pushback makes it retryable',
      );
      expect(GrpcRetryMiddleware.defaultRetryEvaluator(Exception('x'), 0), isFalse);
    });
  });
}
