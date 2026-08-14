import 'dart:convert';

import 'package:auth_model/src/connect/connect_authentication_client.dart';
import 'package:auth_model/src/model/credentials/refresh_token.dart';
import 'package:auth_model/src/proto/auth/v1/auth.pb.dart' as rpc;
import 'package:flutter_test/flutter_test.dart';

/// Builds an unsigned JWT with the given payload — enough for the client-side `exp` decode.
String _jwt(Map<String, Object?> payload) {
  String seg(Object o) => base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${seg(<String, Object?>{'alg': 'none'})}.${seg(payload)}.sig';
}

String _accessJwt() {
  final exp = DateTime.now().toUtc().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
  return _jwt(<String, Object?>{'exp': exp});
}

void main() {
  group('ConnectAuthenticationClient.mapRefreshResponse (refresh-token rotation — RFC 6749 §6)', () {
    test('keeps the previous refresh token when the response omits a rotated one', () {
      final result = rpc.TokenPair()
        ..accessToken = _accessJwt()
        ..refreshToken = ''; // server signals "keep using the current refresh token"

      final creds = ConnectAuthenticationClient.mapRefreshResponse(result, const RefreshToken('old-refresh'));

      expect(
        creds.refreshToken.value,
        equals('old-refresh'),
        reason: 'an empty rotated token must NOT overwrite the old one',
      );
    });

    test('replaces the previous refresh token when the response rotates it', () {
      final result = rpc.TokenPair()
        ..accessToken = _accessJwt()
        ..refreshToken = 'new-refresh';

      final creds = ConnectAuthenticationClient.mapRefreshResponse(result, const RefreshToken('old-refresh'));

      expect(creds.refreshToken.value, equals('new-refresh'));
    });

    test('always rotates the access token from the response JWT', () {
      final jwt = _accessJwt();
      final result = rpc.TokenPair()
        ..accessToken = jwt
        ..refreshToken = 'new-refresh';

      final creds = ConnectAuthenticationClient.mapRefreshResponse(result, const RefreshToken('old-refresh'));

      expect(creds.accessToken.token, equals(jwt));
    });
  });
}
