import 'dart:async';
import 'dart:math' as math;

import 'package:auth_app/_core/api/http/api_client.dart';
import 'package:auth_app/_core/api/http/middlewares/authentication_middleware.dart';
import 'package:auth_app/_core/api/http/middlewares/retry_middleware.dart';
import 'package:auth_app/_core/api/http/middlewares/timeout_middleware.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_model/core_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Builds [AccessCredentials] carrying [token], valid for an hour.
AccessCredentials _creds(String token) => AccessCredentials(
  accessToken: AccessToken(token: token, expiry: DateTime.now().toUtc().add(const Duration(hours: 1))),
  refreshToken: 'refresh-$token',
);

void main() {
  // Drives the real ApiClient + middleware pipeline (the order the app uses:
  // Retry → Authentication (attach + 401-refresh-retry) → Timeout → http) over a MockClient.
  ApiClient buildClient({
    required http.Client client,
    required Future<AccessCredentials?> Function() getToken,
    Future<AccessCredentials?> Function(String usedToken)? refresh,
    bool Function(Object error, int attempt)? retryEvaluator,
    CancelToken? Function()? sessionToken,
    Duration timeout = const Duration(seconds: 5),
  }) => ApiClient(
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
      AuthenticationMiddleware(
        getToken: getToken,
        refreshCredentials: refresh ?? (_) async => null,
        logOut: () {},
      ).call,
      TimeoutMiddleware(duration: timeout).call,
    ],
  );

  group('401 → refresh → retry-once', () {
    test('refreshes once and retries the original request with the new token', () async {
      var current = 'A';
      var refreshCalls = 0;
      final seenAuth = <String?>[];
      final sawCsrf = <bool>[];

      final mock = MockClient((request) async {
        final auth = request.headers[kAuthorization];
        seenAuth.add(auth);
        // The long-lived refresh token must never ride along on normal requests.
        sawCsrf.add(request.headers.keys.any((k) => k.toLowerCase() == 'x-csrf-token'));
        return auth == 'Bearer B' ? http.Response('ok', 200) : http.Response('nope', 401);
      });

      final api = buildClient(
        client: mock,
        getToken: () async => _creds(current),
        refresh: (used) async {
          refreshCalls++;
          current = 'B';
          return _creds('B');
        },
      );

      final res = await api.get('/data');
      expect(res.statusCode, 200);
      expect(await res.toText(), 'ok');
      expect(refreshCalls, 1, reason: 'single refresh');
      // The retry must use a fresh (un-finalized) clone — otherwise MockClient's
      // second finalize() throws StateError and this would fail with a network error.
      expect(seenAuth, ['Bearer A', 'Bearer B']);
      expect(sawCsrf, everyElement(isFalse), reason: 'refresh token never rides along on normal requests');
    });

    test('a 401 that recurs after refresh fails with auth error and does not loop', () async {
      var refreshCalls = 0;
      final mock = MockClient((_) async => http.Response('nope', 401));
      final api = buildClient(
        client: mock,
        getToken: () async => _creds('A'),
        refresh: (_) async {
          refreshCalls++;
          return _creds('B');
        },
      );

      await expectLater(api.get('/data'), throwsA(isA<ApiClientException$Authentication>()));
      expect(refreshCalls, 1);
    });

    test(r'missing credentials fail with $Authentication without sending the request', () async {
      var sent = 0;
      final mock = MockClient((_) async {
        sent++;
        return http.Response('ok', 200);
      });
      final api = buildClient(client: mock, getToken: () async => null);

      await expectLater(api.get('/data'), throwsA(isA<ApiClientException$Authentication>()));
      expect(sent, 0, reason: 'no token → request never reaches the wire, and is not retried');
    });

    test('refresh returning null surfaces an auth error without retrying', () async {
      var attempts = 0;
      final mock = MockClient((_) async {
        attempts++;
        return http.Response('nope', 401);
      });
      final api = buildClient(client: mock, getToken: () async => _creds('A'), refresh: (_) async => null);

      await expectLater(api.get('/data'), throwsA(isA<ApiClientException$Authentication>()));
      expect(attempts, 1, reason: 'no retry when refresh fails');
    });

    test('a transient refresh failure (throws) propagates without logging out', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      final mock = MockClient((_) async => http.Response('nope', 401));
      final api = ApiClient(
        baseUrl: () => Uri.parse('https://api.test'),
        client: mock,
        middlewares: <ApiClientMiddleware>[
          AuthenticationMiddleware(
            getToken: () async => _creds('A'),
            refreshCredentials: (_) async {
              refreshCalls++;
              throw Exception('transient blip'); // session intact ⇒ must NOT log out
            },
            logOut: () => loggedOut = true,
          ).call,
        ],
      );

      await expectLater(api.get('/data'), throwsA(isA<Exception>()));
      expect(refreshCalls, 1, reason: 'refresh attempted once on the 401');
      expect(loggedOut, isFalse, reason: 'a transient (throwing) refresh must NOT end the session');
    });

    test('a request opting out via kNoRetryContextKey is not refresh-retried on 401', () async {
      var refreshCalls = 0;
      var attempts = 0;
      final mock = MockClient((_) async {
        attempts++;
        return http.Response('nope', 401);
      });
      final api = buildClient(
        client: mock,
        getToken: () async => _creds('A'),
        refresh: (_) async {
          refreshCalls++;
          return _creds('B');
        },
      );

      await expectLater(
        api.get('/data', context: <String, Object?>{kNoRetryContextKey: true}),
        throwsA(isA<ApiClientException$Authentication>()),
      );
      expect(refreshCalls, 0, reason: 'kNoRetryContextKey opts out of the 401 refresh-retry');
      expect(attempts, 1, reason: 'request sent once, not refresh-retried');
    });

    test('403 is surfaced without refresh or logout', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      final mock = MockClient((_) async => http.Response('forbidden', 403));
      final api = ApiClient(
        baseUrl: () => Uri.parse('https://api.test'),
        client: mock,
        middlewares: <ApiClientMiddleware>[
          AuthenticationMiddleware(
            getToken: () async => _creds('A'),
            refreshCredentials: (_) async {
              refreshCalls++;
              return _creds('B');
            },
            logOut: () => loggedOut = true,
          ).call,
        ],
      );

      await expectLater(api.get('/data'), throwsA(isA<ApiClientException$Authentication>()));
      expect(refreshCalls, 0, reason: '403 is authorization, not refreshable');
      expect(loggedOut, isFalse, reason: '403 does not end the session');
    });

    test('unauthenticated path: no token attached, no refresh', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      String? seenAuth = 'unset';
      final mock = MockClient((request) async {
        seenAuth = request.headers[kAuthorization];
        return http.Response('ok', 200);
      });
      final api = ApiClient(
        baseUrl: () => Uri.parse('https://api.test'),
        client: mock,
        middlewares: <ApiClientMiddleware>[
          AuthenticationMiddleware(
            getToken: () async => throw StateError('getToken must not be called on a public path'),
            refreshCredentials: (_) async {
              refreshCalls++;
              return _creds('B');
            },
            logOut: () => loggedOut = true,
            unauthenticatedPaths: const {'/login'},
          ).call,
        ],
      );

      final res = await api.post('/login', body: {'u': 'x'});
      expect(res.statusCode, 200);
      expect(seenAuth, isNull, reason: 'no Authorization header on a public path');
      expect(refreshCalls, 0);
      expect(loggedOut, isFalse);
    });

    test('unauthenticated path: 401 logs out and rethrows without refreshing', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      final mock = MockClient((_) async => http.Response('bad refresh token', 401));
      final api = ApiClient(
        baseUrl: () => Uri.parse('https://api.test'),
        client: mock,
        middlewares: <ApiClientMiddleware>[
          AuthenticationMiddleware(
            getToken: () async => _creds('A'),
            refreshCredentials: (_) async {
              refreshCalls++;
              return _creds('B');
            },
            logOut: () => loggedOut = true,
            unauthenticatedPaths: const {'/auth/refresh'},
          ).call,
        ],
      );

      await expectLater(
        api.post('/auth/refresh', body: <String, Object?>{}),
        throwsA(isA<ApiClientException$Authentication>()),
      );
      expect(refreshCalls, 0, reason: 'public paths do not refresh');
      expect(loggedOut, isTrue, reason: 'a 401 on a public path logs out (e.g. rejected refresh token)');
    });
  });

  group('RetryMiddleware', () {
    test('retries a 503 then succeeds', () async {
      var attempts = 0;
      final mock = MockClient((_) async {
        attempts++;
        return attempts == 1 ? http.Response('busy', 503) : http.Response('ok', 200);
      });
      final api = buildClient(client: mock, getToken: () async => _creds('A'));

      final res = await api.get('/data');
      expect(res.statusCode, 200);
      expect(attempts, 2);
    });

    test('does not retry a non-idempotent POST by default', () async {
      var attempts = 0;
      final mock = MockClient((_) async {
        attempts++;
        return http.Response('busy', 503);
      });
      final api = buildClient(client: mock, getToken: () async => _creds('A'));

      await expectLater(api.post('/data', body: {'x': 1}), throwsA(isA<ApiClientException$Network>()));
      expect(attempts, 1, reason: 'POST is not idempotent — not auto-retried');
    });

    test('retries a POST when explicitly opted in', () async {
      var attempts = 0;
      final mock = MockClient((_) async {
        attempts++;
        return attempts == 1 ? http.Response('busy', 503) : http.Response('ok', 200);
      });
      final api = buildClient(client: mock, getToken: () async => _creds('A'));

      final res = await api.post('/data', body: {'x': 1}, context: {kRetryNonIdempotentContextKey: true});
      expect(res.statusCode, 200);
      expect(attempts, 2);
    });

    test('does not retry a non-transient 404 (default policy)', () async {
      var attempts = 0;
      final mock = MockClient((_) async {
        attempts++;
        return http.Response('missing', 404);
      });
      final api = buildClient(client: mock, getToken: () async => _creds('A'));

      await expectLater(api.get('/data'), throwsA(isA<ApiClientException$Network>()));
      expect(attempts, 1, reason: '4xx client errors are not transient');
    });

    test('a custom retryEvaluator overrides the default policy', () async {
      var attempts = 0;
      final mock = MockClient((_) async {
        attempts++;
        return attempts == 1 ? http.Response('missing', 404) : http.Response('ok', 200);
      });
      // Force-retry even a 404 (which the default policy would not retry).
      final api = buildClient(client: mock, getToken: () async => _creds('A'), retryEvaluator: (_, _) => true);

      final res = await api.get('/data');
      expect(res.statusCode, 200);
      expect(attempts, 2);
    });
  });

  group('RetryMiddleware.defaultRetryEvaluator', () {
    test('retries only transient network/5xx/429 errors', () {
      ApiClientException$Network net(int code) =>
          ApiClientException$Network(code: 'x', message: 'x', statusCode: code);
      for (final code in [0, 408, 425, 429, 500, 502, 503, 504, 509]) {
        expect(RetryMiddleware.defaultRetryEvaluator(net(code), 0), isTrue, reason: 'transient $code');
      }
      for (final code in [400, 401, 403, 404, 409, 422, 501]) {
        expect(RetryMiddleware.defaultRetryEvaluator(net(code), 0), isFalse, reason: 'non-transient $code');
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
      final api = buildClient(
        client: mock,
        getToken: () async => _creds('A'),
        timeout: const Duration(milliseconds: 30),
      );

      await expectLater(api.get('/slow'), throwsA(isA<ApiClientException$Timeout>()));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(attempts, 1, reason: 'timeout is not retried');
      expect(aborted, isTrue, reason: 'timeout cancels the request token (frees the socket)');
    });
  });

  group('Cancellation', () {
    test(r'cancel() surfaces $Cancelled to the caller', () async {
      final mock = MockClient.streaming((request, _) async {
        await (request as http.Abortable).abortTrigger; // completes when the token is cancelled
        throw http.RequestAbortedException(request.url);
      });
      final api = buildClient(client: mock, getToken: () async => _creds('A'));

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
      final api = buildClient(client: mock, getToken: () async => _creds('A'), sessionToken: () => session);

      final future = api.get('/slow');
      unawaited(Future<void>.delayed(const Duration(milliseconds: 20), session.cancel));

      await expectLater(future, throwsA(isA<ApiClientException$Cancelled>()));
    });

    test('a completed request leaves no retained link on the session token (no leak)', () async {
      final session = CancelToken();
      final mock = MockClient((_) async => http.Response('ok', 200));
      final api = buildClient(client: mock, getToken: () async => _creds('A'), sessionToken: () => session);

      await api.get('/data');
      await Future<void>.delayed(Duration.zero); // let whenComplete(detach) run

      expect(session.debugLinkedCount, 0);
    });

    test('an in-flight request is retained, then released when the session is cancelled', () async {
      final session = CancelToken();
      final mock = MockClient.streaming((request, _) async {
        await (request as http.Abortable).abortTrigger;
        throw http.RequestAbortedException(request.url);
      });
      final api = buildClient(client: mock, getToken: () async => _creds('A'), sessionToken: () => session);

      final future = api.get('/slow');
      expect(session.debugLinkedCount, 1, reason: 'retained while in-flight');

      session.cancel();
      await expectLater(future, throwsA(isA<ApiClientException$Cancelled>()));
      expect(session.debugLinkedCount, 0, reason: 'cancel clears linked children');
    });

    test('a construction failure (unsupported body) retains no link on the session token', () {
      final session = CancelToken();
      final mock = MockClient((_) async => http.Response('ok', 200));
      final api = buildClient(client: mock, getToken: () async => _creds('A'), sessionToken: () => session);

      // The body switch throws synchronously before the session is linked, so nothing leaks.
      expect(() => api.post('/x', body: DateTime.now()), throwsArgumentError);
      expect(session.debugLinkedCount, 0, reason: 'no link retained when construction fails');
    });

    test('a multipart construction failure retains no link on the session token', () async {
      final session = CancelToken();
      final mock = MockClient((_) async => http.Response('ok', 200));
      final api = buildClient(client: mock, getToken: () async => _creds('A'), sessionToken: () => session);

      // A non-JSON-encodable field fails encoding before the session is linked.
      await expectLater(
        api.postMultipart('/x', body: <String, Object?>{'f': <Object?>[DateTime.now()]}),
        throwsA(isA<ApiClientException$Client>()),
      );
      expect(session.debugLinkedCount, 0, reason: 'no link retained when multipart construction fails');
    });
  });

  group('CancelToken.link', () {
    test('cancelling the parent cancels linked children', () {
      final parent = CancelToken();
      final child = CancelToken();
      parent.link(child);
      expect(parent.debugLinkedCount, 1);

      parent.cancel();
      expect(child.isCancelled, isTrue);
      expect(parent.debugLinkedCount, 0);
    });

    test('detach stops retaining and prevents later cancellation', () {
      final parent = CancelToken();
      final child = CancelToken();
      parent.link(child)();

      expect(parent.debugLinkedCount, 0);
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

  ApiClient bareClient(http.Client client, {int? maxResponseSize, bool Function(int)? validateStatus}) => ApiClient(
    baseUrl: () => Uri.parse('https://api.test'),
    client: client,
    maxResponseSize: maxResponseSize ?? 15 * 1024 * 1024,
    validateStatus: validateStatus,
  );

  group('Query parameter serialization', () {
    test('List values become repeated keys; null and empty list drop the key', () async {
      Uri? seen;
      final mock = MockClient((request) async {
        seen = request.url;
        return http.Response('ok', 200);
      });

      await bareClient(mock).get('/data', queryParameters: {'id': [1, 2], 'q': 'a', 'skip': null, 'empty': <int>[]});

      expect(seen!.queryParametersAll['id'], ['1', '2']);
      expect(seen!.queryParameters['q'], 'a');
      expect(seen!.queryParametersAll.containsKey('skip'), isFalse);
      expect(seen!.queryParametersAll.containsKey('empty'), isFalse);
    });
  });

  group('validateStatus', () {
    test('a custom predicate makes a 404 a success', () async {
      final mock = MockClient((_) async => http.Response('body', 404));
      final res = await bareClient(mock, validateStatus: (c) => c == 404).get('/x');
      expect(res.statusCode, 404);
      expect(await res.toText(), 'body');
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
        throwsA(isA<ApiClientException$Client>().having((e) => e.code, 'code', 'response_too_large')),
      );
    });

    test('stream: true bypasses the size cap', () async {
      final mock = MockClient((_) async => http.Response('x' * 100, 200));
      final res = await bareClient(mock, maxResponseSize: 10).get('/x', stream: true);
      expect((await res.toBytes()).length, 100);
    });

    test('maxResponseSize 0 disables the cap', () async {
      final mock = MockClient((_) async => http.Response('x' * 100, 200));
      final res = await bareClient(mock, maxResponseSize: 0).get('/x');
      expect((await res.toBytes()).length, 100);
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
      final res = await bareClient(mock).get('/x', onReceiveProgress: (received, total) => events.add([received, total]));
      await res.toBytes();
      expect(events, [
        [3, 5],
        [5, 5],
      ]);
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
      expect(await res.toJsonList(), [1, 2, 3]);
    });

    test('toJson on an array body throws FormatException', () async {
      final mock = MockClient((_) async => http.Response('[1,2,3]', 200));
      final res = await bareClient(mock).get('/x');
      await expectLater(res.toJson(), throwsFormatException);
    });

    test('toJson still parses an object body', () async {
      final mock = MockClient((_) async => http.Response('{"a":1}', 200));
      final res = await bareClient(mock).get('/x');
      expect(await res.toJson(), {'a': 1});
    });

    test('a large body (> isolate threshold) decodes correctly via compute', () async {
      final big = 'x' * (kJsonIsolateThreshold + 1000); // ensure we exceed the threshold
      final mock = MockClient((_) async => http.Response('{"big":"$big"}', 200));
      final res = await bareClient(mock).get('/x');
      final json = await res.toJson();
      expect((json['big']! as String).length, big.length);
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
      expect(res.statusCode, 200);
      expect(received, [1, 2, 3, 4, 5]);
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

      await expectLater(api.get('/data'), throwsA(isA<ApiClientException$Network>()));
      expect(attempts, 1, reason: 'budget exhausted after the first attempt — no retry');
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
      expect((e.data! as Map)['body'], {'code': 'validation_error', 'message': 'Email taken'});
    });

    test('a non-JSON error body is captured as text', () async {
      final mock = MockClient((_) async => http.Response('boom', 500));
      final e = await failOf(() => bareClient(mock).get('/x'));
      expect((e.data! as Map)['body'], 'boom');
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
      expect(data['retry-after'], '5');
      expect(data['body'], {'m': 1});
    });

    test('an oversized error body is skipped (no body key), still typed', () async {
      final mock = MockClient((_) async => http.Response('x' * 100, 500));
      final e = await failOf(() => bareClient(mock, maxResponseSize: 10).get('/x'));
      expect(e, isA<ApiClientException$Network>());
      expect((e.data! as Map).containsKey('body'), isFalse);
    });
  });
}
