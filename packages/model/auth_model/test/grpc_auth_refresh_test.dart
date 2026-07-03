import 'package:auth_model/auth_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

AccessCredentials _creds(String token) => AccessCredentials(
  accessToken: AccessToken(token: token, expiry: DateTime.now().toUtc().add(const Duration(hours: 1))),
  refreshToken: RefreshToken('r-$token'),
);

void main() {
  group('GrpcAuthenticationMiddleware reactive refresh', () {
    test('UNAUTHENTICATED → single refresh → retry once with the rotated token', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      final seenAuth = <String?>[];
      final sawRefreshTokenHeader = <bool>[];

      Future<void> invoker(String path, Map<String, String> metadata) async {
        final auth = metadata['authorization'];
        seenAuth.add(auth);
        // The long-lived refresh token must never ride along on normal calls.
        sawRefreshTokenHeader.add(metadata.keys.any((k) => k.toLowerCase() == 'refresh-token'));
        if (auth != 'Bearer B') throw const GrpcError.unauthenticated('nope');
        // success on the rotated token
      }

      final mw = GrpcAuthenticationMiddleware(
        getToken: () async => _creds('A'),
        refreshCredentials: (used) async {
          refreshCalls++;
          return _creds('B');
        },
        onAuthError: () => loggedOut = true,
      );

      await mw.call(invoker)('/users.v1.UsersService/List', <String, String>{});

      expect(refreshCalls, 1, reason: 'one refresh for the wave');
      expect(seenAuth, ['Bearer A', 'Bearer B'], reason: 'retry carries the new token');
      expect(sawRefreshTokenHeader, everyElement(isFalse), reason: 'refresh token never rides along on normal calls');
      expect(loggedOut, isFalse);
    });

    test('refresh returning null logs out and rethrows without a second attempt', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      var attempts = 0;

      Future<void> invoker(String path, Map<String, String> metadata) async {
        attempts++;
        throw const GrpcError.unauthenticated('nope');
      }

      final mw = GrpcAuthenticationMiddleware(
        getToken: () async => _creds('A'),
        refreshCredentials: (used) async {
          refreshCalls++;
          return null; // refresh failed
        },
        onAuthError: () => loggedOut = true,
      );

      await expectLater(
        mw.call(invoker)('/users.v1.UsersService/List', <String, String>{}),
        throwsA(isA<GrpcError>()),
      );
      expect(refreshCalls, 1);
      expect(attempts, 1, reason: 'no retry when refresh fails');
      expect(loggedOut, isTrue);
    });

    test('session-ending public path (RefreshTokens): no token, no refresh, but logout on auth error', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      String? seenAuth = 'unset';

      Future<void> invoker(String path, Map<String, String> metadata) async {
        seenAuth = metadata['authorization'];
        throw const GrpcError.unauthenticated('invalid refresh token');
      }

      final mw = GrpcAuthenticationMiddleware(
        getToken: () async => _creds('A'),
        refreshCredentials: (used) async {
          refreshCalls++;
          return _creds('B');
        },
        onAuthError: () => loggedOut = true,
        unauthenticatedPaths: const {kAuthServiceRefreshTokensPath},
        sessionEndingPaths: const {kAuthServiceRefreshTokensPath},
      );

      await expectLater(
        mw.call(invoker)(kAuthServiceRefreshTokensPath, <String, String>{}),
        throwsA(isA<GrpcError>()),
      );
      expect(refreshCalls, 0, reason: 'public paths do not refresh');
      expect(seenAuth, isNull, reason: 'no token attached on public paths');
      expect(loggedOut, isTrue, reason: 'a rejected refresh token ends the session');
    });

    test('non-session-ending public path (Authenticate): UNAUTHENTICATED is a flow error, NOT a logout', () async {
      var loggedOut = false;

      Future<void> invoker(String path, Map<String, String> metadata) async =>
          throw const GrpcError.unauthenticated('bad password / wrong MFA code');

      final mw = GrpcAuthenticationMiddleware(
        getToken: () async => _creds('A'),
        refreshCredentials: (used) async => _creds('B'),
        onAuthError: () => loggedOut = true,
        unauthenticatedPaths: const {'/auth.v2.AuthService/Authenticate', kAuthServiceRefreshTokensPath},
        sessionEndingPaths: const {kAuthServiceRefreshTokensPath},
      );

      await expectLater(
        mw.call(invoker)('/auth.v2.AuthService/Authenticate', <String, String>{}),
        throwsA(isA<GrpcError>()),
      );
      expect(loggedOut, isFalse, reason: 'a rejected sign-in must not tear down a (possibly other) session');
    });

    test('transient refreshCredentials failure propagates WITHOUT logout (A3)', () async {
      var loggedOut = false;
      var attempts = 0;

      Future<void> invoker(String path, Map<String, String> metadata) async {
        attempts++;
        throw const GrpcError.unauthenticated('nope');
      }

      final mw = GrpcAuthenticationMiddleware(
        getToken: () async => _creds('A'),
        refreshCredentials: (used) async => throw const GrpcError.unavailable('network blip'),
        onAuthError: () => loggedOut = true,
      );

      await expectLater(
        mw.call(invoker)('/users.v1.UsersService/List', <String, String>{}),
        throwsA(isA<GrpcError>()),
      );
      expect(attempts, 1, reason: 'no retry when the refresh itself failed');
      expect(loggedOut, isFalse, reason: 'a transient refresh failure keeps the session (A3)');
    });

    test('a retry that returns PERMISSION_DENIED rethrows WITHOUT logout', () async {
      var loggedOut = false;

      Future<void> invoker(String path, Map<String, String> metadata) async {
        if (metadata['authorization'] == 'Bearer B') throw const GrpcError.permissionDenied('forbidden');
        throw const GrpcError.unauthenticated('expired');
      }

      final mw = GrpcAuthenticationMiddleware(
        getToken: () async => _creds('A'),
        refreshCredentials: (used) async => _creds('B'),
        onAuthError: () => loggedOut = true,
      );

      await expectLater(
        mw.call(invoker)('/users.v1.UsersService/List', <String, String>{}),
        throwsA(isA<GrpcError>()),
      );
      expect(loggedOut, isFalse, reason: '403 after a successful refresh is authorization, not a broken session');
    });

    test('missing credentials (getToken → null) logs out and throws UNAUTHENTICATED, no invoke', () async {
      var loggedOut = false;
      var attempts = 0;

      Future<void> invoker(String path, Map<String, String> metadata) async => attempts++;

      final mw = GrpcAuthenticationMiddleware(
        getToken: () async => null,
        refreshCredentials: (used) async => _creds('B'),
        onAuthError: () => loggedOut = true,
      );

      await expectLater(
        mw.call(invoker)('/users.v1.UsersService/List', <String, String>{}),
        throwsA(isA<GrpcError>()),
      );
      expect(attempts, 0, reason: 'no call is attempted without a token');
      expect(loggedOut, isTrue);
    });

    test('transient getToken failure propagates WITHOUT logout (A3)', () async {
      var loggedOut = false;

      Future<void> invoker(String path, Map<String, String> metadata) async {}

      final mw = GrpcAuthenticationMiddleware(
        getToken: () async => throw const GrpcError.unavailable('secure-storage hiccup'),
        refreshCredentials: (used) async => _creds('B'),
        onAuthError: () => loggedOut = true,
      );

      await expectLater(
        mw.call(invoker)('/users.v1.UsersService/List', <String, String>{}),
        throwsA(isA<GrpcError>()),
      );
      expect(loggedOut, isFalse, reason: 'a transient credential-resolution failure is not a logout (A3)');
    });

    test('forwards the exact attached access token as usedAccessToken', () async {
      String? forwarded;

      Future<void> invoker(String path, Map<String, String> metadata) async {
        if (metadata['authorization'] != 'Bearer B') throw const GrpcError.unauthenticated('expired');
      }

      final mw = GrpcAuthenticationMiddleware(
        getToken: () async => _creds('A'),
        refreshCredentials: (used) async {
          forwarded = used;
          return _creds('B');
        },
        onAuthError: () {},
      );

      await mw.call(invoker)('/users.v1.UsersService/List', <String, String>{});
      expect(forwarded, 'A', reason: 'the raw token that was rejected is forwarded to the single-flight guard');
    });

    test('PERMISSION_DENIED (403) on an authenticated path: no refresh, no retry, no logout', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      var attempts = 0;

      Future<void> invoker(String path, Map<String, String> metadata) async {
        attempts++;
        throw const GrpcError.permissionDenied('forbidden');
      }

      final mw = GrpcAuthenticationMiddleware(
        getToken: () async => _creds('A'),
        refreshCredentials: (used) async {
          refreshCalls++;
          return _creds('B');
        },
        onAuthError: () => loggedOut = true,
      );

      await expectLater(
        mw.call(invoker)('/users.v1.UsersService/List', <String, String>{}),
        throwsA(isA<GrpcError>()),
      );
      expect(attempts, 1, reason: '403 is not retried');
      expect(refreshCalls, 0, reason: '403 does not trigger a refresh (same roles)');
      expect(loggedOut, isFalse, reason: '403 is authorization, not a session failure — no logout');
    });
  });

  group('GrpcAuthenticationMiddleware streaming (repair without replay)', () {
    test('UNAUTHENTICATED repairs the session (refresh) but does NOT replay the stream or log out', () async {
      var refreshCalls = 0;
      var loggedOut = false;
      var attempts = 0;

      Future<void> invoker(String path, Map<String, String> metadata) async {
        attempts++;
        throw const GrpcError.unauthenticated('nope');
      }

      final mw = GrpcAuthenticationMiddleware(
        getToken: () async => _creds('A'),
        refreshCredentials: (used) async {
          refreshCalls++;
          return _creds('B'); // repair succeeds
        },
        onAuthError: () => loggedOut = true,
      );

      await expectLater(
        mw.callStreaming(invoker)('/users.v2.UserService/ListUsers', <String, String>{}),
        throwsA(isA<GrpcError>()),
      );
      expect(attempts, 1, reason: 'a consumed stream is never replayed (caller resubscribes)');
      expect(refreshCalls, 1, reason: 'streaming DOES repair the session on 401 (A3), just without replay');
      expect(loggedOut, isFalse, reason: 'a recoverable streaming 401 must not tear down the session');
    });

    test('UNAUTHENTICATED with a definitive refresh failure logs out', () async {
      var loggedOut = false;

      Future<void> invoker(String path, Map<String, String> metadata) async =>
          throw const GrpcError.unauthenticated('nope');

      final mw = GrpcAuthenticationMiddleware(
        getToken: () async => _creds('A'),
        refreshCredentials: (used) async => null, // definitive rejection
        onAuthError: () => loggedOut = true,
      );

      await expectLater(
        mw.callStreaming(invoker)('/users.v2.UserService/ListUsers', <String, String>{}),
        throwsA(isA<GrpcError>()),
      );
      expect(loggedOut, isTrue, reason: 'a definitively unrecoverable streaming 401 ends the session');
    });

    test('UNAUTHENTICATED with a transient refresh failure propagates WITHOUT logout (A3)', () async {
      var loggedOut = false;

      Future<void> invoker(String path, Map<String, String> metadata) async =>
          throw const GrpcError.unauthenticated('nope');

      final mw = GrpcAuthenticationMiddleware(
        getToken: () async => _creds('A'),
        refreshCredentials: (used) async => throw const GrpcError.unavailable('network blip'),
        onAuthError: () => loggedOut = true,
      );

      await expectLater(
        mw.callStreaming(invoker)('/users.v2.UserService/ListUsers', <String, String>{}),
        throwsA(isA<GrpcError>()),
      );
      expect(loggedOut, isFalse, reason: 'a transient refresh failure keeps the session (A3)');
    });

    test('happy path attaches the token and does not log out', () async {
      var loggedOut = false;
      final seenAuth = <String?>[];

      Future<void> invoker(String path, Map<String, String> metadata) async => seenAuth.add(metadata['authorization']);

      final mw = GrpcAuthenticationMiddleware(
        getToken: () async => _creds('A'),
        refreshCredentials: (used) async => _creds('B'), // required, but streaming never refreshes
        onAuthError: () => loggedOut = true,
      );

      await mw.callStreaming(invoker)('/users.v2.UserService/ListUsers', <String, String>{});
      expect(seenAuth, ['Bearer A']);
      expect(loggedOut, isFalse);
    });
  });
}
