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

    test('public (unauthenticated) path: no token, no refresh, but logout on auth error', () async {
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
        unauthenticatedPaths: const {'/auth.v2.AuthService/RefreshTokens'},
      );

      await expectLater(
        mw.call(invoker)('/auth.v2.AuthService/RefreshTokens', <String, String>{}),
        throwsA(isA<GrpcError>()),
      );
      expect(refreshCalls, 0, reason: 'public paths do not refresh');
      expect(seenAuth, isNull, reason: 'no token attached on public paths');
      expect(loggedOut, isTrue, reason: 'auth error on a public path still logs out');
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

  group('GrpcAuthenticationMiddleware streaming (no replay-retry)', () {
    test('UNAUTHENTICATED on a stream logs out and surfaces — without a second invoke', () async {
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
          return _creds('B'); // a refresh IS available, but streaming must not use it
        },
        onAuthError: () => loggedOut = true,
      );

      await expectLater(
        mw.callStreaming(invoker)('/users.v2.UserService/ListUsers', <String, String>{}),
        throwsA(isA<GrpcError>()),
      );
      expect(attempts, 1, reason: 'streaming request is not replayed (no re-listen → no StateError)');
      expect(refreshCalls, 0, reason: 'streaming does not reactively refresh');
      expect(loggedOut, isTrue, reason: 'an unrecoverable streaming 401 ends the session');
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
