import 'dart:convert';

import 'package:auth_model/src/connect/authentication_converter.dart';
import 'package:auth_model/src/model/credentials/auth_result.dart';
import 'package:auth_model/src/model/role/role.dart';
import 'package:auth_model/src/proto/auth/v1/auth.pb.dart' as rpc;
import 'package:connect_model/connect_model.dart' as core;
import 'package:flutter_test/flutter_test.dart';

/// Minimal decodable JWT: only the payload segment is parsed (`AccessToken.fromJwtToken` reads `exp`).
String _jwt({required int exp}) =>
    'header.${base64Url.encode(utf8.encode(jsonEncode(<String, Object>{'exp': exp}))).replaceAll('=', '')}.signature';

void main() {
  group('proto <-> domain role mapping (A11 — privilege-correctness path)', () {
    test('maps each known role both directions', () {
      expect(core.UserRole.USER_ROLE_ADMIN.toRole(), equals(UserRole.admin));
      expect(core.UserRole.USER_ROLE_USER.toRole(), equals(UserRole.user));
      expect(core.UserRole.USER_ROLE_GUEST.toRole(), equals(UserRole.guest));

      expect(UserRole.admin.toProtoRole(), equals(core.UserRole.USER_ROLE_ADMIN));
      expect(UserRole.user.toProtoRole(), equals(core.UserRole.USER_ROLE_USER));
      expect(UserRole.guest.toProtoRole(), equals(core.UserRole.USER_ROLE_GUEST));
    });

    test('an unknown/unspecified proto role degrades to the least-privileged guest', () {
      expect(core.UserRole.USER_ROLE_UNSPECIFIED.toRole(), equals(UserRole.guest));
    });
  });

  group('AuthResponse -> AuthResult mapping (issuance)', () {
    test('SUCCESS without a refresh token maps to a failed result, not a poisoned session', () {
      // Unlike a refresh response (RFC 6749 §6: omitted token = keep the current one), issuance has
      // no previous refresh token — an empty one would poison the first refresh into a spurious
      // logout, so the converter must fail the sign-in cleanly.
      final response = rpc.AuthResponse()
        ..status = rpc.AuthStatus.AUTH_STATUS_SUCCESS
        ..tokens = (rpc.TokenPair()..accessToken = _jwt(exp: 4102444800)); // refresh_token omitted -> ''

      expect(response.toAuthResult(), isA<AuthResultFailed>());
    });

    test('SUCCESS with both tokens maps to AuthResultSuccess (regression)', () {
      final response = rpc.AuthResponse()
        ..status = rpc.AuthStatus.AUTH_STATUS_SUCCESS
        ..tokens = (rpc.TokenPair()
          ..accessToken = _jwt(exp: 4102444800)
          ..refreshToken = 'rt-1');

      final result = response.toAuthResult();
      expect(result, isA<AuthResultSuccess>());
      expect((result as AuthResultSuccess).credentials.refreshToken.value, equals('rt-1'));
    });
  });
}
