import 'dart:async';

import 'package:auth_model/src/connect/authorization.dart';
import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:connect_model/connect_model.dart';
import 'package:connectrpc/connect.dart';
// VoidCallback is the single platform-neutral typedef from core_model (NOT dart:ui), so this
// package stays web-safe (A1).
import 'package:core_model/core_model.dart' show VoidCallback;
import 'package:meta/meta.dart';

/// PUBLIC `auth.v1.AuthService` paths — no token attach, no refresh-retry. Single source of truth,
/// asserted against the generated stubs by a test (A19). `VerifyMfa` and `ConfirmVerification` are
/// public because the caller has no access token yet; `RequestVerification` is deliberately absent —
/// it is an authenticated resend (S1).
const Set<String> kAuthServicePublicPaths = <String>{
  '/auth.v1.AuthService/Authenticate',
  '/auth.v1.AuthService/SignUp',
  '/auth.v1.AuthService/SignOut',
  '/auth.v1.AuthService/VerifyMfa',
  '/auth.v1.AuthService/RecoveryStart',
  '/auth.v1.AuthService/RecoveryConfirm',
  kAuthServiceRefreshTokensPath,
  '/auth.v1.AuthService/ConfirmVerification',
  // OAuth
  '/auth.v1.AuthService/GetOAuthUrl',
  '/auth.v1.AuthService/ExchangeOAuthCode',
};

/// The refresh-token RPC: an auth-code rejection HERE is definitive session death; on the other
/// public paths it is a flow error — see [sessionEndingPaths].
const String kAuthServiceRefreshTokensPath = '/auth.v1.AuthService/RefreshTokens';

/// {@template connect_authentication_middleware}
/// Middleware for handling authentication in Connect RPC requests.
/// [ConnectAuthenticationMiddleware] middleware is responsible for managing the authentication token
/// {@endtemplate}
@immutable
class ConnectAuthenticationMiddleware extends ConnectMiddleware {
  /// {@macro connect_authentication_middleware}
  const ConnectAuthenticationMiddleware({
    required this.getToken,
    required this.refreshCredentials,
    required this.onAuthError,
    this.unauthenticatedPaths = const <String>{},
    this.sessionEndingPaths = const <String>{},
  });

  /// Resolves the current credentials; expected to proactively refresh an expiring token
  /// (single-flight in the repository).
  final Future<AccessCredentials?> Function() getToken;

  /// Single-flight refresh for the just-rejected access token. Contract: rotated credentials on
  /// success; `null` on a definitive rejection (session already ended); a throw is transient-shaped
  /// (incl. a request whose session ended before the refresh ran) — the call fails, no logout.
  final Future<AccessCredentials?> Function(String usedAccessToken) refreshCredentials;

  /// Fire-and-forget logout signal (idempotent, routed via the auth bus — A26): no credentials,
  /// or an `UNAUTHENTICATED` that refresh could not recover.
  final VoidCallback onAuthError;

  final Set<String> unauthenticatedPaths;

  /// Subset of [unauthenticatedPaths] whose auth-code rejection is DEFINITIVE for the stored
  /// session (the refresh endpoint): fires [onAuthError]. Other public-path auth errors are flow
  /// errors, not session death.
  final Set<String> sessionEndingPaths;

  @override
  ConnectMiddlewareHandler handle(ConnectMiddlewareHandler invoker) => (path, metadata) async {
    if (unauthenticatedPaths.contains(path)) return _public(invoker, path, metadata);

    final credentials = await _resolveCredentials();
    try {
      await invoker(path, _withToken(metadata, credentials));
    } on ConnectException catch (e) {
      // 401 → refresh once + retry once; logout only on a definitive failure (a 2nd 401 = broken
      // session). 403 → surface as-is: no refresh, no retry, no logout.
      if (e.code == Code.unauthenticated) {
        final fresh = await refreshCredentials(credentials.accessToken.token);
        if (fresh != null && fresh.accessToken.token.isNotEmpty) {
          try {
            await invoker(path, _withToken(metadata, fresh)); // retry once with the rotated token
            return;
          } on ConnectException catch (err) {
            if (err.code == Code.unauthenticated) onAuthError(); // fresh token still 401 → broken session
            rethrow;
          }
        }
        // Definitive rejection (repo already cleared creds + ended the session) — log out.
        onAuthError();
        rethrow;
      }
      // 403 / non-auth codes → surface as-is.
      rethrow;
    }
  };

  @override
  ConnectMiddlewareHandler handleStreaming(ConnectMiddlewareHandler invoker) => (path, metadata) async {
    if (unauthenticatedPaths.contains(path)) return _public(invoker, path, metadata);

    final credentials = await _resolveCredentials();
    // Repair-without-replay: a consumed request stream can't be re-invoked, so on UNAUTHENTICATED
    // we refresh (single-flight) but never replay — the caller resubscribes with the rotated token.
    // Logout only on a definitive refresh failure; the original error is always rethrown (A3).
    try {
      await invoker(path, _withToken(metadata, credentials));
    } on ConnectException catch (e) {
      if (e.code == Code.unauthenticated) {
        final fresh = await refreshCredentials(credentials.accessToken.token);
        if (fresh == null || fresh.accessToken.token.isEmpty) onAuthError();
      }
      rethrow;
    }
  };

  /// Public endpoints: no token, no refresh-retry. Logout ONLY on a [sessionEndingPaths] auth
  /// error (rejected refresh token); other public-path auth errors are flow errors.
  Future<void> _public(ConnectMiddlewareHandler invoker, String path, Map<String, String> metadata) async {
    try {
      await invoker(path, metadata);
    } on ConnectException catch (e) {
      if (sessionEndingPaths.contains(path) && _isAuthError(e)) onAuthError();
      rethrow;
    }
  }

  /// Resolves the current credentials. Logout only on a definitively absent token (`null`/empty);
  /// a transient resolution failure propagates as-is — no logout (A3).
  Future<AccessCredentials> _resolveCredentials() async {
    final c = await getToken();
    if (c == null || c.accessToken.token.isEmpty) {
      onAuthError();
      throw ConnectException(Code.unauthenticated, 'Authentication token is null or empty');
    }
    return c;
  }

  /// Fresh metadata copy (the original may be unmodifiable) carrying only the access token via
  /// [AccessToken.authorizationHeaderValue]; the refresh token never rides on data calls.
  Map<String, String> _withToken(Map<String, String> metadata, AccessCredentials c) =>
      Map<String, String>.of(metadata)..[kAuthorizationHeader] = c.accessToken.authorizationHeaderValue;

  /// Auth-code check for the public path only; on the data path logout is gated on
  /// `unauthenticated` alone (403 is surfaced, never a logout).
  static bool _isAuthError(ConnectException e) => e.code == Code.unauthenticated || e.code == Code.permissionDenied;
}
