import 'dart:async';

import 'package:auth_model/auth_model.dart';
import 'package:grpc/grpc.dart' as $grpc;

/// A gRPC authenticator for automatic token refresh.
///
/// Handles transparently refreshing/caching tokens with race condition protection.
class GrpcAuthenticator {
  GrpcAuthenticator({required CredentialsCallbacks credentialsManager}) : _credentialsManager = credentialsManager;

  final CredentialsCallbacks _credentialsManager;
  AccessToken? _accessToken;
  Completer<AccessToken?>? _refreshCompleter;

  $grpc.CallOptions get toCallOptions => $grpc.CallOptions(providers: [authenticate]);

  Future<void> authenticate(Map<String, String> metadata, String uri) async {
    final accessToken = await _getValidToken();

    if (accessToken == null) {
      _credentialsManager.authHandler?.handleAuthenticationError();
      if (!_credentialsManager.allowAnonymous) {
        throw const $grpc.GrpcError.unauthenticated('Require Authentication.');
      }
      return;
    }

    _credentialsManager.authHandler?.handleAuthenticated();
    metadata['authorization'] = '${accessToken.type} ${accessToken.token}';
  }

  Future<AccessToken?> _getValidToken() async {
    // Wait for ongoing refresh
    if (_refreshCompleter != null) return _refreshCompleter!.future;

    // Use cached token if valid
    if (_accessToken case final token? when !token.expiresSoon) {
      return token;
    }

    // Get fresh credentials
    final credentials = await _credentialsManager.getAccessCredentials();
    if (credentials == null) return _accessToken = null;

    final token = credentials.accessToken;

    // Use token if valid
    if (!token.expiresSoon) return _accessToken = token;

    // Refresh expired token
    _refreshCompleter = Completer<AccessToken?>();
    try {
      final refreshed = await _credentialsManager.getRefreshTokens(credentials.refreshToken);
      _accessToken = refreshed?.accessToken;
      _refreshCompleter!.complete(_accessToken);
      return _accessToken;
    } catch (error, stackTrace) {
      _accessToken = null;
      _refreshCompleter!.completeError(error, stackTrace);
      _credentialsManager.authHandler?.handleAuthenticationError();
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }
}
