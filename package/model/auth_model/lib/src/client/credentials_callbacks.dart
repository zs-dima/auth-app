import 'dart:async';

import 'package:auth_model/auth_model.dart';

/// Callback to get/refresh tokens
/// This callback is used for initial connection
/// and for refreshing expired tokens.
///
/// If method returns null then connection will be established without token.
///
/// {@category Client}
/// {@category Entity}
typedef AccessCredentialsCallback = FutureOr<AccessCredentials?> Function();

typedef RefreshTokensCallback = FutureOr<AccessCredentials?> Function(RefreshToken refreshToken);

class CredentialsCallbacks {
  final AccessCredentialsCallback getAccessCredentials;
  final RefreshTokensCallback refreshTokens;
  IAuthenticationHandler? authHandler;
  final bool allowAnonymous;

  CredentialsCallbacks({
    required this.getAccessCredentials,
    required this.refreshTokens,
    this.authHandler,
    this.allowAnonymous = false,
  });
}
