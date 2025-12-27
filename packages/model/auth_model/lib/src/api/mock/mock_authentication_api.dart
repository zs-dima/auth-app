/*import 'dart:async';

import 'package:auth_model/src/api/i_authentication_api.dart';
import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:auth_model/src/model/credentials/access_token.dart';
import 'package:auth_model/src/model/credentials/refresh_token.dart';
import 'package:auth_model/src/model/credentials/sign_in_data.dart';
import 'package:auth_model/src/model/user/auth_user.dart';
import 'package:auth_model/src/model/user/user_id.dart';
import 'package:core_model/core_model.dart';

class MockAuthenticationApi implements IAuthenticationApi {
  const MockAuthenticationApi();

  AccessCredentials get _testCredentials => AccessCredentials(
        accessToken: AccessToken(
          token: 'accessToken',
          expiry: DateTime.now().add(const Duration(days: 1)).toUtc(),
        ),
        refreshToken: 'refreshToken',
      );

  @override
  Future<AuthenticatedUser> signIn(ISignInData data, IDeviceInfo deviceInfo) => Future<AuthenticatedUser>.delayed(
        const Duration(seconds: 1),
        () => AuthenticatedUser(
          credentials: _testCredentials,
          userEmail: data.login,
        ),
      );

  @override
  Future<void> signOut() => Future<void>.delayed(
        const Duration(seconds: 1),
        () {},
      );

  @override
  Future<bool> resetPassword(String email) => Future<bool>.delayed(
        const Duration(seconds: 1),
        () => true,
      );

  @override
  Future<bool> setPassword(UserId userId, String email, String password) => Future<bool>.delayed(
        const Duration(seconds: 1),
        () => true,
      );

  @override
  Future<AccessCredentials> refreshTokens(RefreshToken refreshToken) async => _testCredentials;

  @override
  Future<bool> validateCredentials() async => true;
}
*/
