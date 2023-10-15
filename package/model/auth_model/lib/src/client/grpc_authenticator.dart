import 'dart:async';

import 'package:auth_model/auth_model.dart';
import 'package:grpc/grpc.dart' as $grpc;

const _tokenExpirationThreshold = Duration(seconds: 30);

/// {@template fresh}
/// A Grpc Authenticator for automatic token refresh.
/// Requires a concrete implementation of [AccessCredentialsCallback] and [RefreshTokensCallback].
/// Handles transparently refreshing/caching tokens.
/// {@endtemplate}+62781
class GrpcAuthenticator {
  GrpcAuthenticator({
    required CredentialsCallbacks credentialsManager,
  }) : _credentialsManager = credentialsManager;

  final CredentialsCallbacks _credentialsManager;
  AccessToken? _accessToken;

  bool get _tokenExpiresSoon =>
      _accessToken!.expiry.subtract(_tokenExpirationThreshold).isBefore(DateTime.now().toUtc());

  FutureOr<void> authenticate(Map<String, String> metadata, String uri) async {
    if (_accessToken == null || _tokenExpiresSoon) {
      try {
        final credentials = await _credentialsManager.getAccessCredentials.call();
        if (credentials == null) return;

        _accessToken = credentials.accessToken;
        if (_accessToken == null || _tokenExpiresSoon) {
          final refresh = await _credentialsManager.refreshTokens(credentials.refreshToken);
          _accessToken = refresh?.accessToken;
        }
        // ignore: avoid_catches_without_on_clauses
      } catch (e, s) {
        _credentialsManager.authHandler?.handleAuthenticationError();
        Error.throwWithStackTrace(e, s);
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

  $grpc.CallOptions get toCallOptions => $grpc.CallOptions(providers: [authenticate]);
}
