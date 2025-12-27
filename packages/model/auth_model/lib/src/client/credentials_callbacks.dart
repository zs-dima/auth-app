import 'dart:async';

import 'package:auth_model/src/client/authentication_handler.dart';
import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:auth_model/src/model/credentials/refresh_token.dart';

/// Callback to get/refresh tokens
/// This callback is used for initial connection
/// and for refreshing expired tokens.
///
/// If method returns null then connection will be established without token.
///
/// {@category Client}
/// {@category Entity}
typedef AccessCredentialsCallback = Future<AccessCredentials?> Function();

typedef RefreshTokensCallback = Future<AccessCredentials?> Function(RefreshToken refreshToken);

class CredentialsCallbacks {
  CredentialsCallbacks({
    required this.getAccessCredentials,
    required this.getRefreshTokens,
    this.authHandler,
    this.allowAnonymous = false,
  });

  final AccessCredentialsCallback getAccessCredentials;
  final RefreshTokensCallback getRefreshTokens;
  IAuthenticationHandler? authHandler;
  final bool allowAnonymous;
}
