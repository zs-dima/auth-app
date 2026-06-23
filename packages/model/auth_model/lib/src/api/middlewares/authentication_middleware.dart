import 'dart:io';
import 'dart:ui';

import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_model/grpc_model.dart';
import 'package:meta/meta.dart';

extension HttpHeadersEx on HttpHeaders {
  static const bearer = 'Bearer';
}

/// {@template grpc_authentication_middleware}
/// Middleware for handling authentication in gRPC requests.
/// [GrpcAuthenticationMiddleware] middleware is responsible for managing the authentication token
/// {@endtemplate}
@immutable
class GrpcAuthenticationMiddleware extends GrpcMiddleware {
  /// {@macro grpc_authentication_middleware}
  const GrpcAuthenticationMiddleware({
    required this.getToken,
    this.refresh,
    this.onAuthError,
    this.unauthenticatedPaths = const <String>{},
  });

  /// Callback to get the authentication token.
  /// This should return a valid token for the API client. Expected to proactively
  /// refresh tokens that are about to expire (single-flight in the repository).
  final Future<AccessCredentials?> Function() getToken;

  /// Forces a single-flight token refresh for the access token that was just
  /// rejected with `UNAUTHENTICATED`, and returns the new credentials (or `null`
  /// when the refresh failed). When provided, an `UNAUTHENTICATED` response is
  /// recovered by refreshing once and retrying the call — instead of logging out
  /// immediately. Mirrors the HTTP `TokenRefreshMiddleware`.
  final Future<AccessCredentials?> Function(String usedAccessToken)? refresh;

  /// Callback when authentication fails (logout). Called when there is no token,
  /// on `PERMISSION_DENIED`, or on `UNAUTHENTICATED` that refresh could not recover.
  final VoidCallback? onAuthError;

  final Set<String> unauthenticatedPaths;

  @override
  ApiClientHandler call(ApiClientHandler invoker) => (path, metadata) async {
    // Public endpoints (sign-in / RefreshTokens / OAuth): no token, no refresh-retry,
    // but still log out on an auth-code error (e.g. an invalid/expired refresh token).
    if (unauthenticatedPaths.contains(path)) {
      try {
        await invoker(path, metadata);
      } on GrpcError catch (e) {
        if (_isAuthError(e)) onAuthError?.call();
        rethrow;
      }
      return;
    }

    // Attach the current credentials.
    AccessCredentials credentials;
    try {
      final c = await getToken();
      // Missing/empty credentials are unrecoverable: log out and fail fast.
      if (c == null || c.accessToken.token.isEmpty)
        throw const GrpcError.unauthenticated('Authentication token is null or empty');
      credentials = c;
    } on Object {
      onAuthError?.call();
      rethrow;
    }

    // The original metadata map may be unmodifiable, so build a fresh copy per attempt.
    // Only the access token rides along on normal calls; the refresh token is sent solely
    // to the RefreshTokens RPC (in its request body), never on every request.
    Map<String, String> withToken(AccessCredentials c) => Map<String, String>.of(metadata)
      ..[HttpHeaders.authorizationHeader] = '${HttpHeadersEx.bearer} ${c.accessToken.token}';

    try {
      await invoker(path, withToken(credentials));
    } on GrpcError catch (e) {
      // Reactive single-flight refresh + retry ONCE, only on UNAUTHENTICATED.
      if (e.code == StatusCode.unauthenticated && refresh != null) {
        final fresh = await refresh!(credentials.accessToken.token);
        if (fresh != null && fresh.accessToken.token.isNotEmpty) {
          try {
            await invoker(path, withToken(fresh)); // retry once with the rotated token
            return;
          } on GrpcError catch (err) {
            if (_isAuthError(err)) onAuthError?.call();
            rethrow;
          }
        }
        // Refresh failed (repo already cleared creds + ended the session) — log out.
        onAuthError?.call();
        rethrow;
      }
      if (_isAuthError(e)) onAuthError?.call();
      rethrow;
    }
  };

  static bool _isAuthError(GrpcError e) =>
      e.code == StatusCode.unauthenticated || e.code == StatusCode.permissionDenied;
}
