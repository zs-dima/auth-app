import 'dart:convert';

import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:auth_model/src/model/credentials/access_token.dart';
import 'package:auth_model/src/model/credentials/refresh_token.dart';
import 'package:auth_model/src/model/user/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

AccessCredentials _creds() => AccessCredentials(
  accessToken: AccessToken(token: 'a', expiry: DateTime.utc(2030)),
  refreshToken: const RefreshToken('r'),
  scopes: const <String>['s1', 's2'],
);

AuthUser _decoded(AuthUser user) => AuthUser.fromJson(jsonDecode(jsonEncode(user.toJson())) as Map<String, Object?>);

void main() {
  group('AuthUser serialization', () {
    test('authenticated user survives a full JSON encode/decode round-trip (==)', () {
      final original = AuthUser.authenticated(credentials: _creds(), userId: 'u-1');
      expect(_decoded(original), equals(original));
    });

    test('authenticated user with lost credentials round-trips (credentials stay null)', () {
      // The "authenticated but credentials lost" state: toJson writes `credentials: null`
      // and fromJson must read that back rather than crash on it.
      const original = AuthenticatedUser(credentials: null, userId: 'u-1');
      final decoded = _decoded(original);
      expect(decoded, isA<AuthenticatedUser>());
      expect((decoded as AuthenticatedUser).credentials, isNull);
      expect(decoded.userId, 'u-1');
      expect(decoded, equals(original));
    });

    test('unauthenticated user round-trips', () {
      expect(_decoded(const AuthUser.unauthenticated()), isA<UnauthenticatedUser>());
    });

    test('AuthenticatedUser.fromJson still rejects invalid json', () {
      expect(() => AuthenticatedUser.fromJson(const <String, Object?>{}), throwsFormatException);
      expect(() => AuthenticatedUser.fromJson(const <String, Object?>{'foo': 'bar'}), throwsFormatException);
    });
  });

  group('AuthUser.copyWith', () {
    test('UnauthenticatedUser.copyWith(userId:) without credentials does not crash', () {
      final user = const AuthUser.unauthenticated().copyWith(userId: 'u-1');
      expect(user, isA<AuthenticatedUser>());
      expect((user as AuthenticatedUser).userId, 'u-1');
      expect(user.credentials, isNull);
    });

    test('UnauthenticatedUser.copyWith() without userId stays unauthenticated', () {
      expect(const AuthUser.unauthenticated().copyWith(credentials: _creds()), isA<UnauthenticatedUser>());
    });

    test('AuthenticatedUser.copyWith preserves and overrides fields', () {
      final original = AuthUser.authenticated(credentials: _creds(), userId: 'u-1');
      expect(original.copyWith(), equals(original));

      final moved = original.copyWith(userId: 'u-2');
      expect(moved, isA<AuthenticatedUser>());
      expect((moved as AuthenticatedUser).userId, 'u-2');
      expect(moved.credentials, equals(_creds()));
    });

    test('AuthenticatedUser.copyWith keeps null credentials null', () {
      const original = AuthenticatedUser(credentials: null, userId: 'u-1');
      final copy = original.copyWith();
      expect(copy.credentials, isNull);
      expect(copy.userId, 'u-1');
    });
  });
}
