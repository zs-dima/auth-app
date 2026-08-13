// ignore_for_file: prefer-explicit-function-type, prefer-const-constructor-declarations

import 'dart:math' as math;

import 'package:connect_model/connect_model.dart';
import 'package:connectrpc/connect.dart';
import 'package:core_model/core_model.dart';
import 'package:flutter_test/flutter_test.dart';

int _zero() => 0;

const _spec = Spec<int, int>('/svc.v1.Service/Method', StreamType.unary, _zero, _zero);

UnaryRequest<int, int> _request([AbortSignal? signal]) =>
    UnaryRequest<int, int>(_spec, 'test://test/svc.v1.Service/Method', Headers(), 1, signal ?? CancelableSignal());

UnaryResponse<int, int> _response(int value, {Headers? headers, Headers? trailers}) =>
    UnaryResponse<int, int>(_spec, headers ?? Headers(), value, trailers ?? Headers());

ConnectException _withPushback(Code code, int pushbackMs, {String key = 'grpc-retry-pushback-ms'}) =>
    ConnectException(code, 'x', metadata: Headers()..[key] = '$pushbackMs');

/// Drives the middleware exactly like the transport does: fold `next`, invoke with a request.
Future<int> _run(ConnectRetryMiddleware middleware, AnyFn<int, int> next, {AbortSignal? signal}) async {
  final response = await middleware.call<int, int>(next)(_request(signal));
  return (response as UnaryResponse<int, int>).message;
}

void main() {
  ConnectRetryMiddleware middleware() => ConnectRetryMiddleware(
    backoff: const RetryBackoff(
      maxRetries: 2,
      baseDelay: Duration(milliseconds: 1),
      maxDelay: Duration(milliseconds: 1),
    ),
    random: math.Random(1),
  );

  group('ConnectRetryMiddleware', () {
    test('retries a transient error (unavailable) then succeeds', () async {
      var attempts = 0;
      final result = await _run(middleware(), (req) async {
        attempts++;
        if (attempts == 1) throw ConnectException(Code.unavailable, 'down');
        return _response(42);
      });

      expect(attempts, 2);
      expect(result, 42);
    });

    test('does not retry UNAUTHENTICATED (owned by the auth middleware)', () async {
      var attempts = 0;
      final call = _run(middleware(), (req) async {
        attempts++;
        throw ConnectException(Code.unauthenticated, 'no');
      });

      await expectLater(call, throwsA(isA<ConnectException>()));
      expect(attempts, 1);
    });

    test('does not retry a non-transient error (notFound)', () async {
      var attempts = 0;
      final call = _run(middleware(), (req) async {
        attempts++;
        throw ConnectException(Code.notFound, 'missing');
      });

      await expectLater(call, throwsA(isA<ConnectException>()));
      expect(attempts, 1);
    });

    test('a path in noRetryPaths passes through with a single attempt (no replay)', () async {
      var attempts = 0;
      final mw = ConnectRetryMiddleware(
        backoff: const RetryBackoff(
          maxRetries: 2,
          baseDelay: Duration(milliseconds: 1),
          maxDelay: Duration(milliseconds: 1),
        ),
        random: math.Random(1),
        noRetryPaths: const {'/svc.v1.Service/Method'},
      );

      final call = _run(mw, (req) async {
        attempts++;
        throw ConnectException(Code.unavailable, 'down');
      });

      await expectLater(call, throwsA(isA<ConnectException>()));
      expect(attempts, 1, reason: 'RefreshTokens-class RPCs must never be replayed');
    });

    test('noRetryPaths naming a different path leaves this call retryable', () async {
      var attempts = 0;
      final mw = ConnectRetryMiddleware(
        backoff: const RetryBackoff(
          maxRetries: 2,
          baseDelay: Duration(milliseconds: 1),
          maxDelay: Duration(milliseconds: 1),
        ),
        random: math.Random(1),
        noRetryPaths: const {'/auth.v1.AuthService/RefreshTokens'},
      );

      final result = await _run(mw, (req) async {
        attempts++;
        if (attempts == 1) throw ConnectException(Code.unavailable, 'down');
        return _response(3);
      });

      expect(attempts, 2);
      expect(result, 3);
    });

    test('does NOT retry RESOURCE_EXHAUSTED without server pushback', () async {
      var attempts = 0;
      final call = _run(middleware(), (req) async {
        attempts++;
        throw ConnectException(Code.resourceExhausted, 'quota');
      });

      await expectLater(call, throwsA(isA<ConnectException>()));
      expect(attempts, 1, reason: 'resourceExhausted is retried only when the server sends pushback');
    });

    test('retries RESOURCE_EXHAUSTED when the server sends a (non-negative) pushback', () async {
      var attempts = 0;
      final result = await _run(middleware(), (req) async {
        attempts++;
        if (attempts == 1) throw _withPushback(Code.resourceExhausted, 1);
        return _response(7);
      });

      expect(attempts, 2);
      expect(result, 7);
    });

    test('reads the pushback under the Connect `trailer-` prefixed key too', () async {
      var attempts = 0;
      final result = await _run(middleware(), (req) async {
        attempts++;
        if (attempts == 1) {
          throw _withPushback(Code.resourceExhausted, 1, key: 'trailer-grpc-retry-pushback-ms');
        }
        return _response(11);
      });

      expect(attempts, 2, reason: 'unary trailing metadata may surface as trailer-prefixed headers over Connect');
      expect(result, 11);
    });

    test('negative pushback forbids retry even for an otherwise-transient code', () async {
      var attempts = 0;
      final call = _run(middleware(), (req) async {
        attempts++;
        throw _withPushback(Code.unavailable, -1);
      });

      await expectLater(call, throwsA(isA<ConnectException>()));
      expect(attempts, 1, reason: 'a negative pushback means do not retry');
    });

    test('a custom retryEvaluator can retry an otherwise non-retryable code', () async {
      var attempts = 0;
      final mw = ConnectRetryMiddleware(
        backoff: const RetryBackoff(
          maxRetries: 2,
          baseDelay: Duration(milliseconds: 1),
          maxDelay: Duration(milliseconds: 1),
        ),
        random: math.Random(1),
        retryEvaluator: (error, attempt) => true, // force retry regardless of code
      );

      final result = await _run(mw, (req) async {
        attempts++;
        if (attempts == 1) throw ConnectException(Code.notFound, 'x');
        return _response(9);
      });

      expect(attempts, 2);
      expect(result, 9);
    });

    test('a custom retryEvaluator cannot retry against a negative pushback (mechanic)', () async {
      var attempts = 0;
      final mw = ConnectRetryMiddleware(
        backoff: const RetryBackoff(
          maxRetries: 2,
          baseDelay: Duration(milliseconds: 1),
          maxDelay: Duration(milliseconds: 1),
        ),
        random: math.Random(1),
        retryEvaluator: (error, attempt) => true, // wants to retry, but the mechanic wins
      );

      final call = _run(mw, (req) async {
        attempts++;
        throw _withPushback(Code.unavailable, -1);
      });

      await expectLater(call, throwsA(isA<ConnectException>()));
      expect(attempts, 1, reason: 'negative pushback is a mechanic; a custom evaluator cannot override it');
    });

    test('streaming requests pass through untouched (no retry wrapping)', () async {
      var invoked = 0;
      final streamRequest = StreamRequest<int, int>(
        const Spec<int, int>('/svc.v1.Service/Stream', StreamType.server, _zero, _zero),
        'test://test/svc.v1.Service/Stream',
        Headers(),
        Stream.value(1),
        CancelableSignal(),
      );
      final response = StreamResponse<int, int>(_spec, Headers(), const Stream<int>.empty(), Headers());

      final result = await middleware().call<int, int>((req) async {
        invoked++;
        expect(identical(req, streamRequest), isTrue, reason: 'the request must be forwarded as-is');
        return response;
      })(streamRequest);

      expect(invoked, 1);
      expect(identical(result, response), isTrue);
    });
  });

  group('ConnectRetryMiddleware response contract', () {
    test('returns the final attempt\'s response with its headers/trailers', () async {
      final response = await middleware().call<int, int>(
        (req) async => _response(5, headers: Headers()..['h'] = '1', trailers: Headers()..['t'] = '2'),
      )(_request());

      final unary = response as UnaryResponse<int, int>;
      expect(unary.message, 5);
      expect(unary.headers['h'], '1');
      expect(unary.trailers['t'], '2');
    });

    test('an aborted signal aborts the in-flight attempt and stops retrying', () async {
      var attempts = 0;
      final signal = CancelableSignal();

      final call = _run(middleware(), (req) {
        attempts++;
        // Mirror the real transport: the in-flight attempt is aborted when the request signal
        // fires (the HTTP/2 layer races the signal and terminates the stream).
        return req.signal.future.then<Response<int, int>>((e) => throw e);
      }, signal: signal);

      final expectation = expectLater(call, throwsA(isA<ConnectException>()));
      signal.cancel();
      await expectation;

      expect(attempts, 1, reason: 'no further attempt after cancellation');
    });
  });

  group('ConnectRetryMiddleware.defaultRetryEvaluator', () {
    test('is public and classifies transient codes (mirrors HTTP)', () {
      expect(ConnectRetryMiddleware.defaultRetryEvaluator(ConnectException(Code.unavailable, 'x'), 0), isTrue);
      expect(ConnectRetryMiddleware.defaultRetryEvaluator(ConnectException(Code.deadlineExceeded, 'x'), 0), isTrue);
      expect(ConnectRetryMiddleware.defaultRetryEvaluator(ConnectException(Code.notFound, 'x'), 0), isFalse);
      expect(ConnectRetryMiddleware.defaultRetryEvaluator(ConnectException(Code.unauthenticated, 'x'), 0), isFalse);
      expect(
        ConnectRetryMiddleware.defaultRetryEvaluator(ConnectException(Code.resourceExhausted, 'x'), 0),
        isFalse,
        reason: 'no server pushback → not retried',
      );
      expect(
        ConnectRetryMiddleware.defaultRetryEvaluator(_withPushback(Code.resourceExhausted, 5), 0),
        isTrue,
        reason: 'a (non-negative) pushback makes it retryable',
      );
      expect(ConnectRetryMiddleware.defaultRetryEvaluator(Exception('x'), 0), isFalse);
    });
  });
}
