import 'dart:convert';

import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:auth_model/src/model/credentials/access_token.dart';
import 'package:auth_model/src/model/credentials/refresh_token.dart';
import 'package:flutter_test/flutter_test.dart';

AccessCredentials _creds() => AccessCredentials(
  accessToken: AccessToken(token: 'a', expiry: DateTime.utc(2030)),
  refreshToken: const RefreshToken('r'),
  scopes: const <String>['s1', 's2'],
);

void main() {
  group('AccessCredentials serialization', () {
    test('survives a full JSON encode/decode round-trip (==)', () {
      final original = _creds();
      final decoded = AccessCredentials.fromJson(jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>);
      expect(decoded, equals(original));
    });

    test('toJson emits accessToken as a nested Map, not the object', () {
      expect(_creds().toJson()['accessToken'], isA<Map<String, dynamic>>());
    });

    test('fromJson tolerates an older blob that omits scopes (no crash on restore)', () {
      final json = _creds().toJson()..remove('scopes');
      final decoded = AccessCredentials.fromJson(jsonDecode(jsonEncode(json)) as Map<String, dynamic>);
      expect(decoded.scopes, isEmpty);
    });
  });

  group('AccessCredentials redaction (no secrets in toString)', () {
    test('toString masks both the access token and the refresh token', () {
      final creds = AccessCredentials(
        accessToken: AccessToken(token: 'secret-access-jwt', expiry: DateTime.utc(2030)),
        refreshToken: const RefreshToken('secret-refresh-value'),
      );
      final str = creds.toString();
      expect(str, isNot(contains('secret-access-jwt')));
      expect(str, isNot(contains('secret-refresh-value')));
      expect(str, contains('***'));
    });
  });
}
