import 'dart:async';

import 'package:auth_model/auth_model.dart';
import 'package:grpc/grpc.dart' as $grpc;

const _tokenExpirationThreshold = Duration(seconds: 30);

extension _StringExtension on AccessToken? {
  bool get expiresSoon => this?.expiry.subtract(_tokenExpirationThreshold).isBefore(DateTime.now().toUtc()) ?? false;
}

/// A gRPC authenticator for automatic token refresh.
///
/// Handles transparently refreshing/caching tokens with race condition protection.
class GrpcAuthenticator {
  final CredentialsCallbacks _credentialsManager;
  AccessToken? _accessToken;
  Completer<AccessToken?>? _refreshCompleter;

  $grpc.CallOptions get toCallOptions => $grpc.CallOptions(providers: [authenticate]);

  GrpcAuthenticator({required CredentialsCallbacks credentialsManager}) : _credentialsManager = credentialsManager;

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
    // If another call is already refreshing, wait for it
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    if (_accessToken != null && !_accessToken.expiresSoon) {
      return _accessToken;
    }

    // Start refresh and protect against concurrent refreshes
    _refreshCompleter = Completer<AccessToken?>();

    try {
      final credentials = await _credentialsManager.getAccessCredentials();
      if (credentials == null) {
        _accessToken = null;
      } else if (credentials.accessToken.expiresSoon) {
        final refreshed = await _credentialsManager.refreshTokens(credentials.refreshToken);
        _accessToken = refreshed?.accessToken;
      } else {
        _accessToken = credentials.accessToken;
      }

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
