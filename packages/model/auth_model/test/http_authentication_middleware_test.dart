import 'package:auth_model/auth_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:http_client/http_client.dart';

AccessCredentials _creds(String token) => AccessCredentials(
  accessToken: AccessToken(token: token, expiry: DateTime.now().toUtc().add(const Duration(hours: 1))),
  refreshToken: RefreshToken('r-$token'),
);

ApiClient _client(MockClient mock, HttpAuthenticationMiddleware mw) => ApiClient(
  baseUrl: () => Uri.parse('https://api.test'),
  client: mock,
  middlewares: <ApiClientMiddleware>[mw.call],
);

void main() {
  group('HttpAuthenticationMiddleware reactive refresh', () {
    test('401 → single refresh → retry once with the rotated token', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      final seenAuth = <String?>[];

      final mock = MockClient((request) async {
        final auth = request.headers['authorization'];
        seenAuth.add(auth);
        // success only on the rotated token; the original token is rejected.
        return http.Response('ok', auth == 'Bearer B' ? 200 : 401);
      });
      final api = _client(
        mock,
        HttpAuthenticationMiddleware(
          getToken: () async => _creds('A'),
          refreshCredentials: (used) async {
            refreshCalls++;
            return _creds('B');
          },
          onAuthError: () => loggedOut = true,
        ),
      );

      await api.get('/data');

      expect(refreshCalls, 1, reason: 'one refresh for the wave');
      expect(seenAuth, ['Bearer A', 'Bearer B'], reason: 'retry carries the new token');
      expect(loggedOut, isFalse);
    });

    test('refresh returning null logs out and rethrows without a second attempt', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      var attempts = 0;

      final mock = MockClient((request) async {
        attempts++;
        return http.Response('no', 401);
      });
      final api = _client(
        mock,
        HttpAuthenticationMiddleware(
          getToken: () async => _creds('A'),
          refreshCredentials: (used) async {
            refreshCalls++;
            return null; // refresh failed
          },
          onAuthError: () => loggedOut = true,
        ),
      );

      await expectLater(api.get('/data'), throwsA(isA<ApiClientException>()));
      expect(refreshCalls, 1);
      expect(attempts, 1, reason: 'no retry when refresh fails');
      expect(loggedOut, isTrue);
    });

    test('session-ending public path (refresh): no token, no refresh, but logout on auth error', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      String? seenAuth = 'unset';

      final mock = MockClient((request) async {
        seenAuth = request.headers['authorization'];
        return http.Response('no', 401);
      });
      final api = _client(
        mock,
        HttpAuthenticationMiddleware(
          getToken: () async => _creds('A'),
          refreshCredentials: (used) async {
            refreshCalls++;
            return _creds('B');
          },
          onAuthError: () => loggedOut = true,
          unauthenticatedPaths: const {'/auth/refresh'},
          sessionEndingPaths: const {'/auth/refresh'},
        ),
      );

      await expectLater(api.get('/auth/refresh'), throwsA(isA<ApiClientException>()));
      expect(refreshCalls, 0, reason: 'public paths do not refresh');
      expect(seenAuth, isNull, reason: 'no token attached on public paths');
      expect(loggedOut, isTrue, reason: 'a rejected refresh token ends the session');
    });

    test('non-session-ending public path (sign-in): a 401 is a flow error, NOT a logout', () async {
      var loggedOut = false;

      final mock = MockClient((request) async => http.Response('bad password', 401));
      final api = _client(
        mock,
        HttpAuthenticationMiddleware(
          getToken: () async => _creds('A'),
          refreshCredentials: (used) async => _creds('B'),
          onAuthError: () => loggedOut = true,
          unauthenticatedPaths: const {'/auth/signin', '/auth/refresh'},
          sessionEndingPaths: const {'/auth/refresh'},
        ),
      );

      await expectLater(api.get('/auth/signin'), throwsA(isA<ApiClientException>()));
      expect(loggedOut, isFalse, reason: 'a rejected sign-in must not tear down a session');
    });

    test('transient refreshCredentials failure propagates WITHOUT logout (A3)', () async {
      var loggedOut = false;
      var attempts = 0;

      final mock = MockClient((request) async {
        attempts++;
        return http.Response('no', 401);
      });
      final api = _client(
        mock,
        HttpAuthenticationMiddleware(
          getToken: () async => _creds('A'),
          refreshCredentials: (used) async => throw const FormatException('network blip'),
          onAuthError: () => loggedOut = true,
        ),
      );

      await expectLater(api.get('/data'), throwsA(isA<FormatException>()));
      expect(attempts, 1, reason: 'no retry when the refresh itself failed');
      expect(loggedOut, isFalse, reason: 'a transient refresh failure keeps the session (A3)');
    });

    test('a retry that returns 403 rethrows WITHOUT logout', () async {
      var loggedOut = false;

      final mock = MockClient((request) async {
        if (request.headers['authorization'] == 'Bearer B') return http.Response('forbidden', 403);
        return http.Response('expired', 401);
      });
      final api = _client(
        mock,
        HttpAuthenticationMiddleware(
          getToken: () async => _creds('A'),
          refreshCredentials: (used) async => _creds('B'),
          onAuthError: () => loggedOut = true,
        ),
      );

      await expectLater(api.get('/data'), throwsA(isA<ApiClientException>()));
      expect(loggedOut, isFalse, reason: '403 after a successful refresh is authorization, not a broken session');
    });

    test('forwards the exact attached access token as usedAccessToken', () async {
      String? forwarded;

      final mock = MockClient(
        (request) async => http.Response('', request.headers['authorization'] == 'Bearer B' ? 200 : 401),
      );
      final api = _client(
        mock,
        HttpAuthenticationMiddleware(
          getToken: () async => _creds('A'),
          refreshCredentials: (used) async {
            forwarded = used;
            return _creds('B');
          },
          onAuthError: () {},
        ),
      );

      await api.get('/data');
      expect(forwarded, 'A', reason: 'the raw token that was rejected is forwarded to the single-flight guard');
    });

    test('403 (forbidden) on an authenticated path: no refresh, no retry, no logout', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      var attempts = 0;

      final mock = MockClient((request) async {
        attempts++;
        return http.Response('forbidden', 403);
      });
      final api = _client(
        mock,
        HttpAuthenticationMiddleware(
          getToken: () async => _creds('A'),
          refreshCredentials: (used) async {
            refreshCalls++;
            return _creds('B');
          },
          onAuthError: () => loggedOut = true,
        ),
      );

      await expectLater(api.get('/data'), throwsA(isA<ApiClientException>()));
      expect(attempts, 1, reason: '403 is not retried');
      expect(refreshCalls, 0, reason: '403 does not trigger a refresh (same roles)');
      expect(loggedOut, isFalse, reason: '403 is authorization, not a session failure — no logout');
    });

    test('missing credentials (getToken → null): logs out and fails fast', () async {
      var loggedOut = false;
      var attempts = 0;

      final mock = MockClient((request) async {
        attempts++;
        return http.Response('ok', 200);
      });
      final api = _client(
        mock,
        HttpAuthenticationMiddleware(
          getToken: () async => null,
          refreshCredentials: (used) async => _creds('B'),
          onAuthError: () => loggedOut = true,
        ),
      );

      await expectLater(api.get('/data'), throwsA(isA<ApiClientException$Authentication>()));
      expect(loggedOut, isTrue);
      expect(attempts, 0, reason: 'no request is sent without credentials');
    });

    test('transient getToken failure propagates WITHOUT logging out (A3)', () async {
      var loggedOut = false;
      var attempts = 0;

      final mock = MockClient((request) async {
        attempts++;
        return http.Response('ok', 200);
      });
      final api = _client(
        mock,
        HttpAuthenticationMiddleware(
          getToken: () async => throw const FormatException('secure-storage hiccup'),
          refreshCredentials: (used) async => _creds('B'),
          onAuthError: () => loggedOut = true,
        ),
      );

      await expectLater(api.get('/data'), throwsA(isA<FormatException>()));
      expect(loggedOut, isFalse, reason: 'a transient resolution failure must not end the session (A3)');
      expect(attempts, 0);
    });

    test('a 2nd 401 after refresh (rotated token still rejected) logs out', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      final seenAuth = <String?>[];

      // Always 401 — even the rotated token is rejected ⇒ broken session.
      final mock = MockClient((request) async {
        seenAuth.add(request.headers['authorization']);
        return http.Response('no', 401);
      });
      final api = _client(
        mock,
        HttpAuthenticationMiddleware(
          getToken: () async => _creds('A'),
          refreshCredentials: (used) async {
            refreshCalls++;
            return _creds('B');
          },
          onAuthError: () => loggedOut = true,
        ),
      );

      await expectLater(api.get('/data'), throwsA(isA<ApiClientException>()));
      expect(refreshCalls, 1, reason: 'one refresh attempt');
      expect(seenAuth, ['Bearer A', 'Bearer B'], reason: 'retried once with the rotated token');
      expect(loggedOut, isTrue, reason: 'a fresh token still 401 ⇒ broken session ⇒ logout');
    });

    test('happy path attaches the token and does not log out', () async {
      var loggedOut = false;
      final seenAuth = <String?>[];

      final mock = MockClient((request) async {
        seenAuth.add(request.headers['authorization']);
        return http.Response('ok', 200);
      });
      final api = _client(
        mock,
        HttpAuthenticationMiddleware(
          getToken: () async => _creds('A'),
          refreshCredentials: (used) async => _creds('B'),
          onAuthError: () => loggedOut = true,
        ),
      );

      await api.get('/data');
      expect(seenAuth, ['Bearer A']);
      expect(loggedOut, isFalse);
    });

    test('kNoRetryContextKey: a 401 repairs the session (refresh) but does NOT resend the body', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      var attempts = 0;
      final seenAuth = <String?>[];

      final mock = MockClient((request) async {
        attempts++;
        seenAuth.add(request.headers['authorization']);
        return http.Response('no', 401);
      });
      final api = _client(
        mock,
        HttpAuthenticationMiddleware(
          getToken: () async => _creds('A'),
          refreshCredentials: (used) async {
            refreshCalls++;
            return _creds('B');
          },
          onAuthError: () => loggedOut = true,
        ),
      );

      await expectLater(
        api.get('/data', context: <String, Object?>{kNoRetryContextKey: true}),
        throwsA(isA<ApiClientException>()),
      );
      expect(attempts, 1, reason: 'opt-out: the body is sent exactly once, never resent');
      expect(refreshCalls, 1, reason: 'kNoRetryContextKey skips the RESEND, not the session repair (A3)');
      expect(seenAuth, ['Bearer A'], reason: 'no replay, so only the original token was seen');
      expect(loggedOut, isFalse, reason: 'the session was repaired; the original 401 surfaces to the caller');
    });

    test('multipart upload + 401: repairs the session (refresh) but does NOT replay the body', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      var attempts = 0;
      final seenAuth = <String?>[];

      final mock = MockClient((request) async {
        attempts++;
        seenAuth.add(request.headers['authorization']);
        return http.Response('no', 401);
      });
      final api = _client(
        mock,
        HttpAuthenticationMiddleware(
          getToken: () async => _creds('A'),
          refreshCredentials: (used) async {
            refreshCalls++;
            return _creds('B');
          },
          onAuthError: () => loggedOut = true,
        ),
      );

      // sendMultipart builds a non-retryable MultipartRequest (canBeRetried == false) and sets
      // kNoRetryContextKey — the body is never replayed, but the session IS repaired (A3) so the
      // caller can resend against the rotated token.
      await expectLater(
        api.sendMultipart('POST', '/upload', body: <String, Object?>{'field': 'v'}),
        throwsA(isA<ApiClientException>()),
      );
      expect(attempts, 1, reason: 'the multipart body is sent exactly once');
      expect(refreshCalls, 1, reason: 'a non-replayable body still repairs the session (A3)');
      expect(seenAuth, ['Bearer A'], reason: 'the body is not replayed, so only the original token was seen');
      expect(loggedOut, isFalse, reason: 'the 401 surfaces to the caller without logout (session repaired)');
    });

    test('non-replayable 401 with a definitive refresh failure logs out', () async {
      var loggedOut = false;

      final mock = MockClient((request) async => http.Response('no', 401));
      final api = _client(
        mock,
        HttpAuthenticationMiddleware(
          getToken: () async => _creds('A'),
          refreshCredentials: (used) async => null, // definitive rejection
          onAuthError: () => loggedOut = true,
        ),
      );

      await expectLater(
        api.get('/data', context: <String, Object?>{kNoRetryContextKey: true}),
        throwsA(isA<ApiClientException>()),
      );
      expect(loggedOut, isTrue, reason: 'a definitive refresh failure ends the session even without replay');
    });
  });
}
