import 'dart:async';

import 'package:auth_model/auth_model.dart';
import 'package:grpc/grpc.dart' as $grpc;

const _tokenExpirationThreshold = Duration(seconds: 30);

extension _StringExtension on AccessToken? {
  bool get expiresSoon => this?.expiry.subtract(_tokenExpirationThreshold).isBefore(DateTime.now().toUtc()) ?? false;
}

/// {@template fresh}
/// A Grpc Authenticator for automatic token refresh.
/// Requires a concrete implementation of [AccessCredentialsCallback] and [RefreshTokensCallback].
/// Handles transparently refreshing/caching tokens.
/// {@endtemplate}
class GrpcAuthenticator {
  final CredentialsCallbacks _credentialsManager;
  AccessToken? _accessToken;

  $grpc.CallOptions get toCallOptions => $grpc.CallOptions(providers: [authenticate]);

  GrpcAuthenticator({
    required CredentialsCallbacks credentialsManager,
  }) : _credentialsManager = credentialsManager;

  Future<void> authenticate(Map<String, String> metadata, String _) async {
    if (_accessToken == null || _accessToken.expiresSoon) {
      try {
        final credentials = await _credentialsManager.getAccessCredentials();
        if (credentials == null) return;

        final accessToken = credentials.accessToken;
        if (accessToken.expiresSoon) {
          final refresh = await _credentialsManager.refreshTokens(credentials.refreshToken);
          _accessToken = refresh?.accessToken;
        } else {
          _accessToken = accessToken;
        }

        // ignore: avoid_catches_without_on_clauses
      } catch (error, s) {
        _credentialsManager.authHandler?.handleAuthenticationError();
        Error.throwWithStackTrace(error, s);
      }
    }

    final accessToken = _accessToken;
    if (accessToken == null) {
      _credentialsManager.authHandler?.handleAuthenticationError();
      throw const $grpc.GrpcError.unauthenticated('Require Authentication.');
    }

    _credentialsManager.authHandler?.handleAuthenticated();

    metadata.addAll({
      'authorization': '${accessToken.type} ${accessToken.token}',
    });
  }
}
