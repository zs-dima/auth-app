import 'dart:async';

import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:auth_model/src/model/credentials/refresh_token.dart';
import 'package:auth_model/src/model/credentials/sign_in_data.dart';
import 'package:auth_model/src/model/user/auth_user.dart';
import 'package:auth_model/src/model/user/user_id.dart';
import 'package:core_model/core_model.dart';

abstract interface class IAuthenticationApi {
  Future<AuthenticatedUser> signIn(ISignInData data, IDeviceInfo deviceInfo);
  Future<void> signOut(String token);

  Future<bool> resetPassword(String email);
  Future<bool> setPassword(UserId userId, String email, String password);

  Future<AccessCredentials?> refreshTokens(String accessToken, RefreshToken refreshToken);
  Future<bool> validateCredentials();
}
