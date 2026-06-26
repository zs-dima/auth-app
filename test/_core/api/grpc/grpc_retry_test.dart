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
  _FakeResponseFuture(this._future);
  final Future<R> _future;

  @override
  Future<Map<String, String>> get headers async => const <String, String>{};
  @override
  Future<Map<String, String>> get trailers async => const <String, String>{};
  @override
  Future<void> cancel() async {}
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
  });
}
