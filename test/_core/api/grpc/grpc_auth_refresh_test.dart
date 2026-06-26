import 'package:auth_model/auth_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

AccessCredentials _creds(String token) => AccessCredentials(
  accessToken: AccessToken(token: token, expiry: DateTime.now().toUtc().add(const Duration(hours: 1))),
  refreshToken: 'r-$token',
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
        refresh: (used) async {
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
        refresh: (used) async {
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
        refresh: (used) async {
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
        refresh: (used) async {
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
}
