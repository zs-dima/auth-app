import 'dart:async';
import 'dart:math' as math;

import 'package:core_model/core_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:http_client/http_client.dart';

void main() {
  // Drives the real ApiClient + middleware pipeline (Retry → Timeout → http) over a MockClient.
  // (Authentication is handled on the gRPC transport; the external HTTP client carries no auth.)
  ApiClient buildClient({
    required http.Client client,
    bool Function(Object error, int attempt)? retryEvaluator,
    CancelToken? Function()? sessionToken,
    Duration timeout = const Duration(seconds: 5),
  }) => .new(
    baseUrl: () => Uri.parse('https://api.test'),
    client: client,
    sessionToken: sessionToken,
    middlewares: <ApiClientMiddleware>[
      RetryMiddleware(
        backoff: const RetryBackoff(
          maxRetries: 2,
          baseDelay: Duration(milliseconds: 1),
          maxDelay: Duration(milliseconds: 1),
        ),
        retryEvaluator: retryEvaluator,
        random: math.Random(1),
      ).call,
      TimeoutMiddleware(duration: timeout).call,
    ],
  );

  group('RetryMiddleware', () {
    test('retries a 503 then succeeds', () async {
      var attempts = 0;
      final mock = MockClient((_) async {
        attempts++;
        return attempts == 1 ? http.Response('busy', 503) : http.Response('ok', 200);
      });
      final api = buildClient(client: mock);

      final res = await api.get('/data');
      expect(res.statusCode, equals(200));
      expect(attempts, equals(2));
    });

    test('does not retry a non-idempotent POST by default', () async {
      var attempts = 0;
      final mock = MockClient((_) async {
        attempts++;
        return http.Response('busy', 503);
      });
      final api = buildClient(client: mock);

      await expectLater(api.post('/data', body: {'x': 1}), throwsA(isA<ApiClientException$Server>()));
      expect(attempts, equals(1), reason: 'POST is not idempotent — not auto-retried');
    });

    test('retries a POST when explicitly opted in', () async {
      var attempts = 0;
      final mock = MockClient((_) async {
        attempts++;
        return attempts == 1 ? http.Response('busy', 503) : http.Response('ok', 200);
      });
      final api = buildClient(client: mock);

      final res = await api.post('/data', body: {'x': 1}, context: {kRetryNonIdempotentContextKey: true});
      expect(res.statusCode, equals(200));
      expect(attempts, equals(2));
    });

    test('does not retry a non-transient 404 (default policy)', () async {
      var attempts = 0;
      final mock = MockClient((_) async {
        attempts++;
        return http.Response('missing', 404);
      });
      final api = buildClient(client: mock);

      await expectLater(api.get('/data'), throwsA(isA<ApiClientException$Request>()));
      expect(attempts, equals(1), reason: '4xx client errors are not transient');
    });

    test('a custom retryEvaluator overrides the default policy', () async {
      var attempts = 0;
      final mock = MockClient((_) async {
        attempts++;
        return attempts == 1 ? http.Response('missing', 404) : http.Response('ok', 200);
      });
      // Force-retry even a 404 (which the default policy would not retry).
      final api = buildClient(client: mock, retryEvaluator: (_, _) => true);

      final res = await api.get('/data');
      expect(res.statusCode, equals(200));
      expect(attempts, equals(2));
    });
  });

  group('RetryMiddleware.defaultRetryEvaluator', () {
    test('retries only transient network/5xx/429 errors', () {
      // Build the realistic subtype per status (mirrors _statusToException); the evaluator keys off
      // the base ApiClientException's statusCode regardless of subtype.
      ApiClientException ex(int code) => switch (code) {
        0 => ApiClientException$Network(code: 'x', message: 'x', statusCode: code),
        401 || 403 => ApiClientException$Authentication(code: 'x', message: 'x', statusCode: code),
        >= 500 => ApiClientException$Server(code: 'x', message: 'x', statusCode: code),
        _ => ApiClientException$Request(code: 'x', message: 'x', statusCode: code),
      };
      for (final code in [0, 408, 425, 429, 500, 502, 503, 504, 509]) {
        expect(RetryMiddleware.defaultRetryEvaluator(ex(code), 0), isTrue, reason: 'transient $code');
      }
      for (final code in [400, 401, 403, 404, 409, 422, 501]) {
        expect(RetryMiddleware.defaultRetryEvaluator(ex(code), 0), isFalse, reason: 'non-transient $code');
      }
    });

    test('never retries auth / cancelled / timeout', () {
      expect(
        RetryMiddleware.defaultRetryEvaluator(
          const ApiClientException$Authentication(code: 'unauthorized', message: 'x', statusCode: 401),
          0,
        ),
        isFalse,
      );
      expect(RetryMiddleware.defaultRetryEvaluator(const ApiClientException$Cancelled(), 0), isFalse);
    });
  });

  group('Timeout', () {
    test(r'throws $Timeout, does not retry, and aborts the socket', () async {
      var attempts = 0;
      var aborted = false;
      final mock = MockClient.streaming((request, _) async {
        attempts++;
        (request as http.Abortable).abortTrigger?.then((_) => aborted = true).ignore();
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return http.StreamedResponse(const Stream<List<int>>.empty(), 200);
      });
      final api = buildClient(client: mock, timeout: const Duration(milliseconds: 30));

      await expectLater(api.get('/slow'), throwsA(isA<ApiClientException$Timeout>()));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(attempts, equals(1), reason: 'timeout is not retried');
      expect(aborted, isTrue, reason: 'timeout cancels the request token (frees the socket)');
    });
  });

  group('Cancellation', () {
    test(r'cancel() surfaces $Cancelled to the caller', () async {
      final mock = MockClient.streaming((request, _) async {
        await (request as http.Abortable).abortTrigger; // completes when the token is cancelled
        throw http.RequestAbortedException(request.url);
      });
      final api = buildClient(client: mock);

      final token = CancelToken();
      final future = api.get('/slow', cancelToken: token);
      unawaited(Future<void>.delayed(const Duration(milliseconds: 20), token.cancel));

      await expectLater(future, throwsA(isA<ApiClientException$Cancelled>()));
    });

    test('cancelling the session token aborts in-flight requests', () async {
      final session = CancelToken();
      final mock = MockClient.streaming((request, _) async {
        await (request as http.Abortable).abortTrigger; // fires when the session is cancelled
        throw http.RequestAbortedException(request.url);
      });
      final api = buildClient(client: mock, sessionToken: () => session);

      final future = api.get('/slow');
      unawaited(Future<void>.delayed(const Duration(milliseconds: 20), session.cancel));

      await expectLater(future, throwsA(isA<ApiClientException$Cancelled>()));
    });

    test('a completed request leaves no retained link on the session token (no leak)', () async {
      final session = CancelToken();
      final mock = MockClient((_) async => http.Response('ok', 200));
      final api = buildClient(client: mock, sessionToken: () => session);

      await api.get('/data');
      await Future<void>.delayed(.zero); // let whenComplete(detach) run

      expect(session.debugLinkedCount, isZero);
    });

    test('an in-flight request is retained, then released when the session is cancelled', () async {
      final session = CancelToken();
      final mock = MockClient.streaming((request, _) async {
        await (request as http.Abortable).abortTrigger;
        throw http.RequestAbortedException(request.url);
      });
      final api = buildClient(client: mock, sessionToken: () => session);

      final future = api.get('/slow');
      expect(session.debugLinkedCount, equals(1), reason: 'retained while in-flight');

      session.cancel();
      await expectLater(future, throwsA(isA<ApiClientException$Cancelled>()));
      expect(session.debugLinkedCount, isZero, reason: 'cancel clears linked children');
    });

    test('a construction failure (unsupported body) retains no link on the session token', () {
      final session = CancelToken();
      final mock = MockClient((_) async => http.Response('ok', 200));
      final api = buildClient(client: mock, sessionToken: () => session);

      // The body switch throws synchronously before the session is linked, so nothing leaks.
      expect(() => api.post('/x', body: DateTime.now()), throwsArgumentError);
      expect(session.debugLinkedCount, isZero, reason: 'no link retained when construction fails');
    });

    test('a multipart construction failure retains no link on the session token', () async {
      final session = CancelToken();
      final mock = MockClient((_) async => http.Response('ok', 200));
      final api = buildClient(client: mock, sessionToken: () => session);

      // A non-JSON-encodable field fails encoding before the session is linked.
      await expectLater(
        api.postMultipart(
          '/x',
          body: <String, Object?>{
            'f': <Object?>[DateTime.now()],
          },
        ),
        throwsA(isA<ApiClientException$Internal>()),
      );
      expect(session.debugLinkedCount, isZero, reason: 'no link retained when multipart construction fails');
    });
  });

  group('CancelToken.link', () {
    test('cancelling the parent cancels linked children', () {
      final parent = CancelToken();
      final child = CancelToken();
      parent.link(child);
      expect(parent.debugLinkedCount, equals(1));

      parent.cancel();
      expect(child.isCancelled, isTrue);
      expect(parent.debugLinkedCount, isZero);
    });

    test('detach stops retaining and prevents later cancellation', () {
      final parent = CancelToken();
      final child = CancelToken();
      parent.link(child)();

      expect(parent.debugLinkedCount, isZero);
      parent.cancel();
      expect(child.isCancelled, isFalse);
    });

    test('linking to an already-cancelled parent cancels the child immediately', () {
      final parent = CancelToken()..cancel();
      final child = CancelToken();
      parent.link(child);
      expect(child.isCancelled, isTrue);
    });
  });

  // --- Dio-parity gaps: query arrays, validateStatus, size/stream/progress, receive timeout ---

  ApiClient bareClient(http.Client client, {int? maxResponseSize, bool Function(int)? validateStatus}) => .new(
    baseUrl: () => Uri.parse('https://api.test'),
    client: client,
    maxResponseSize: maxResponseSize ?? (15 * 1024 * 1024),
    validateStatus: validateStatus,
  );

  group('Query parameter serialization', () {
    test('List values become repeated keys; null and empty list drop the key', () async {
      Uri? seen;
      final mock = MockClient((request) async {
        seen = request.url;
        return http.Response('ok', 200);
      });

      await bareClient(mock).get(
        '/data',
        queryParameters: {
          'id': [1, 2],
          'q': 'a',
          'skip': null,
          'empty': <int>[],
        },
      );

      expect(seen!.queryParametersAll['id'], equals(['1', '2']));
      expect(seen!.queryParameters['q'], equals('a'));
      expect(seen!.queryParametersAll.containsKey('skip'), isFalse);
      expect(seen!.queryParametersAll.containsKey('empty'), isFalse);
    });

    test('an absolute URL keeps its own query and honors queryParameters', () async {
      Uri? seen;
      final mock = MockClient((request) async {
        seen = request.url;
        return http.Response('ok', 200);
      });

      await bareClient(mock).get('https://cdn.example.com/file.png?present=1', queryParameters: {'extra': 'x'});

      expect(seen!.host, equals('cdn.example.com'));
      expect(seen!.queryParameters['present'], equals('1'), reason: 'the URL\'s own query survives');
      expect(seen!.queryParameters['extra'], equals('x'), reason: 'queryParameters are merged, not silently dropped');
    });
  });

  group('ApiClient.clone', () {
    test('preserves the response-size cap', () async {
      final mock = MockClient((_) async => http.Response('x' * 100, 200));
      // `client` is the one thing clone() cannot carry over (ownership) — pass it explicitly.
      final copy = bareClient(mock, maxResponseSize: 10).clone(client: mock);

      await expectLater(
        copy.get('/x'),
        throwsA(isA<ApiClientException$Internal>().having((e) => e.code, 'code', 'response_too_large')),
      );
    });

    test('preserves the validateStatus predicate', () async {
      final mock = MockClient((_) async => http.Response('body', 404));
      final copy = bareClient(mock, validateStatus: (c) => c == 404).clone(client: mock);

      final res = await copy.get('/x');
      expect(res.statusCode, equals(404), reason: 'the custom success predicate survives the clone');
    });

    test('preserves the session-cancellation binding', () async {
      final session = CancelToken()..cancel(); // an already-ended session cancels new links immediately
      final mock = MockClient.streaming((request, _) async {
        await (request as http.Abortable).abortTrigger; // already completed via the session link
        throw http.RequestAbortedException(request.url);
      });
      final origin = ApiClient(
        baseUrl: () => Uri.parse('https://api.test'),
        client: mock,
        sessionToken: () => session,
      );

      await expectLater(
        origin.clone(client: mock).get('/x'),
        throwsA(isA<ApiClientException$Cancelled>()),
        reason: 'the clone stays bound to the session token',
      );
    });
  });

  group('validateStatus', () {
    test('a custom predicate makes a 404 a success', () async {
      final mock = MockClient((_) async => http.Response('body', 404));
      final res = await bareClient(mock, validateStatus: (c) => c == 404).get('/x');
      expect(res.statusCode, equals(404));
      expect(await res.toText(), equals('body'));
    });

    test('a predicate rejecting 200 throws', () async {
      final mock = MockClient((_) async => http.Response('ok', 200));
      await expectLater(bareClient(mock, validateStatus: (_) => false).get('/x'), throwsA(isA<ApiClientException>()));
    });

    test(r'the default still maps 401 to $Authentication', () async {
      final mock = MockClient((_) async => http.Response('no', 401));
      await expectLater(bareClient(mock).get('/x'), throwsA(isA<ApiClientException$Authentication>()));
    });
  });

  group('Response size limit & streaming', () {
    test('rejects a response larger than maxResponseSize', () async {
      final mock = MockClient((_) async => http.Response('x' * 100, 200));
      await expectLater(
        bareClient(mock, maxResponseSize: 10).get('/x'),
        throwsA(isA<ApiClientException$Internal>().having((e) => e.code, 'code', 'response_too_large')),
      );
    });

    test('stream: true bypasses the size cap', () async {
      final mock = MockClient((_) async => http.Response('x' * 100, 200));
      final res = await bareClient(mock, maxResponseSize: 10).get('/x', stream: true);
      expect(await res.toBytes(), hasLength(100));
    });

    test('maxResponseSize 0 disables the cap', () async {
      final mock = MockClient((_) async => http.Response('x' * 100, 200));
      final res = await bareClient(mock, maxResponseSize: 0).get('/x');
      expect(await res.toBytes(), hasLength(100));
    });
  });

  group('Receive progress', () {
    test('reports cumulative bytes with total from content-length', () async {
      final mock = MockClient.streaming(
        (_, _) async => http.StreamedResponse(
          Stream<List<int>>.fromIterable([
            [1, 2, 3],
            [4, 5],
          ]),
          200,
          contentLength: 5,
        ),
      );
      final events = <List<int>>[];
      final res = await bareClient(
        mock,
      ).get('/x', onReceiveProgress: (received, total) => events.add([received, total]));
      await res.toBytes();
      expect(
        events,
        equals([
          [3, 5],
          [5, 5],
        ]),
      );
    });
  });

  group('Receive timeout', () {
    test('fires when the body stalls mid-stream and aborts the socket', () async {
      // A StreamController models a real socket (pushed chunks). It emits one chunk then
      // stays open and idle, so the receive idle-timer trips.
      final body = StreamController<List<int>>();
      var aborted = false;
      final mock = MockClient.streaming((request, _) async {
        (request as http.Abortable).abortTrigger?.then((_) => aborted = true).ignore();
        body.add(const [1, 2]); // one chunk, then the body goes idle (never closes)
        return http.StreamedResponse(body.stream, 200, contentLength: 10);
      });
      final api = ApiClient(
        baseUrl: () => Uri.parse('https://api.test'),
        client: mock,
        middlewares: <ApiClientMiddleware>[
          const TimeoutMiddleware(
            connectTimeout: Duration(seconds: 5),
            receiveTimeout: Duration(milliseconds: 30),
          ).call,
        ],
      );

      final res = await api.get('/slow');
      await expectLater(res.toBytes(), throwsA(isA<ApiClientException$Timeout>()));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(aborted, isTrue, reason: 'receive timeout cancels the request token (frees the socket)');
      await body.close();
    });
  });

  // --- Backported from sidekick: JSON arrays, canBeRetried, ArgumentError, postStream ---

  group('JSON array support', () {
    test('toJsonList parses a top-level array', () async {
      final mock = MockClient((_) async => http.Response('[1,2,3]', 200));
      final res = await bareClient(mock).get('/x');
      expect(await res.toJsonList(), equals([1, 2, 3]));
    });

    test('toJson on an array body throws FormatException', () async {
      final mock = MockClient((_) async => http.Response('[1,2,3]', 200));
      final res = await bareClient(mock).get('/x');
      await expectLater(res.toJson(), throwsFormatException);
    });

    test('toJson still parses an object body', () async {
      final mock = MockClient((_) async => http.Response('{"a":1}', 200));
      final res = await bareClient(mock).get('/x');
      expect(await res.toJson(), equals({'a': 1}));
    });

    test('a large body (> isolate threshold) decodes correctly via compute', () async {
      final big = 'x' * (kJsonIsolateThreshold + 1000); // ensure we exceed the threshold
      final mock = MockClient((_) async => http.Response('{"big":"$big"}', 200));
      final res = await bareClient(mock).get('/x');
      final json = await res.toJson();
      expect(json['big']! as String, hasLength(big.length));
    });
  });

  group('canBeRetried', () {
    test('true for an in-memory Request, false for multipart/streamed', () {
      final uri = Uri.parse('https://api.test/x');
      expect(ApiClientRequest(http.Request('GET', uri)).canBeRetried, isTrue);
      expect(ApiClientRequest(http.MultipartRequest('POST', uri)).canBeRetried, isFalse);
      expect(ApiClientRequest(http.StreamedRequest('POST', uri)).canBeRetried, isFalse);
    });
  });

  group('Unsupported body', () {
    test('throws ArgumentError (not just an assert)', () {
      final mock = MockClient((_) async => http.Response('ok', 200));
      expect(() => bareClient(mock).post('/x', body: 42), throwsArgumentError);
    });
  });

  group('postStream', () {
    test('pipes the chunked body to the wire', () async {
      List<int>? received;
      final mock = MockClient((request) async {
        received = request.bodyBytes;
        return http.Response('ok', 200);
      });
      final res = await bareClient(mock).postStream(
        '/upload',
        bodyStream: Stream<List<int>>.fromIterable([
          [1, 2, 3],
          [4, 5],
        ]),
        contentLength: 5,
      );
      expect(res.statusCode, equals(200));
      expect(received, equals([1, 2, 3, 4, 5]));
    });

    test('cancelling an upload stops draining the body stream', () async {
      // Pre-fix the pump subscription was fire-and-forget: the socket aborted but the source
      // (a file read, an encoder) kept being drained into a request nobody was reading.
      var bodyCancelled = false;
      final body = StreamController<List<int>>(onCancel: () => bodyCancelled = true);
      final mock = MockClient.streaming((request, _) async {
        await (request as http.Abortable).abortTrigger;
        throw http.RequestAbortedException(request.url);
      });

      final token = CancelToken();
      final future = bareClient(
        mock,
      ).postStream('/upload', bodyStream: body.stream, contentLength: 100, cancelToken: token);
      await Future<void>.delayed(.zero); // let the pump attach before aborting
      token.cancel();

      await expectLater(future, throwsA(isA<ApiClientException$Cancelled>()));
      await pumpEventQueue();

      expect(bodyCancelled, isTrue, reason: 'the aborted upload must release the body stream');
      await body.close();
    });
  });

  group('Retry — budget', () {
    test('the total budget (maxElapsed) stops retries early', () async {
      var attempts = 0;
      // Each attempt takes ~30ms; with a 10ms budget the first failure already exceeds it.
      final mock = MockClient((_) async {
        attempts++;
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return http.Response('busy', 503);
      });
      final api = ApiClient(
        baseUrl: () => Uri.parse('https://api.test'),
        client: mock,
        middlewares: <ApiClientMiddleware>[
          RetryMiddleware(
            backoff: const RetryBackoff(
              maxRetries: 3,
              baseDelay: Duration(milliseconds: 1),
              maxDelay: Duration(milliseconds: 1),
              maxElapsed: Duration(milliseconds: 10),
            ),
            random: math.Random(1),
          ).call,
        ],
      );

      await expectLater(api.get('/data'), throwsA(isA<ApiClientException$Server>()));
      expect(attempts, equals(1), reason: 'budget exhausted after the first attempt — no retry');
    });
  });

  group('Error body capture', () {
    Future<ApiClientException> failOf(Future<Object?> Function() send) async {
      try {
        await send();
      } on ApiClientException catch (e) {
        return e;
      }
      throw StateError('expected an ApiClientException');
    }

    test('a JSON error body is parsed into data[body]', () async {
      final mock = MockClient(
        (_) async => http.Response('{"code":"validation_error","message":"Email taken"}', 422),
      );
      final e = await failOf(() => bareClient(mock).get('/x'));
      expect((e.data! as Map)['body'], equals({'code': 'validation_error', 'message': 'Email taken'}));
    });

    test('a non-JSON error body is captured as text', () async {
      final mock = MockClient((_) async => http.Response('boom', 500));
      final e = await failOf(() => bareClient(mock).get('/x'));
      expect((e.data! as Map)['body'], equals('boom'));
    });

    test('an empty error body adds no body key', () async {
      final mock = MockClient((_) async => http.Response('', 404));
      final e = await failOf(() => bareClient(mock).get('/x'));
      expect((e.data! as Map).containsKey('body'), isFalse);
    });

    test('429 carries both Retry-After and the body', () async {
      final mock = MockClient(
        (_) async => http.Response('{"m":1}', 429, headers: {'retry-after': '5'}),
      );
      final e = await failOf(() => bareClient(mock).get('/x'));
      final data = e.data! as Map;
      expect(data['retry-after'], equals('5'));
      expect(data['body'], equals({'m': 1}));
    });

    test('an oversized error body is skipped (no body key), still typed', () async {
      final mock = MockClient((_) async => http.Response('x' * 100, 500));
      final e = await failOf(() => bareClient(mock, maxResponseSize: 10).get('/x'));
      expect(e, isA<ApiClientException$Server>());
      expect((e.data! as Map).containsKey('body'), isFalse);
    });
  });
}
