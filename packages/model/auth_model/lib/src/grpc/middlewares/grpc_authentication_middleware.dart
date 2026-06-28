import 'dart:async';

// VoidCallback is the platform-neutral typedef from authentication_handler (NOT dart:ui), so this
// package stays web-safe (A1).
import 'package:auth_model/src/client/authentication_handler.dart' show VoidCallback;
import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_model/grpc_model.dart';
import 'package:meta/meta.dart';

/// gRPC metadata key carrying the bearer token. gRPC metadata keys are lowercase ASCII —
/// kept as a plain constant so this platform-agnostic package never reaches for
/// `dart:io`'s `HttpHeaders` (which breaks the web build — see A1).
const _kAuthorizationKey = 'authorization';
const _kBearerScheme = 'Bearer';

/// Fully-qualified gRPC method paths of `auth.v2.AuthService` that are PUBLIC — no access token is
/// attached and a `401` does not trigger refresh-retry. Single source of truth co-located with the
/// auth middleware (A19); a test asserts every entry matches a real generated method path.
///
/// `VerifyMfa` (called after `Authenticate` returns MFA_REQUIRED, with only a challenge token) and
/// `ConfirmVerification` (email/phone verification before sign-in) are public: the caller has no
/// access token yet, so omitting them made the middleware attach a missing token and force a
/// spurious logout — the bug A19 fixes.
///
/// `RequestVerification` is intentionally NOT here: per `auth.proto` it is a resend "for a verified
/// user / when the token expired", i.e. an authenticated call that must carry the access token (S1).
const Set<String> kAuthServicePublicPaths = <String>{
  '/auth.v2.AuthService/Authenticate',
  '/auth.v2.AuthService/SignUp',
  '/auth.v2.AuthService/SignOut',
  '/auth.v2.AuthService/VerifyMfa',
  '/auth.v2.AuthService/RecoveryStart',
  '/auth.v2.AuthService/RecoveryConfirm',
  '/auth.v2.AuthService/RefreshTokens',
  '/auth.v2.AuthService/ConfirmVerification',
  // OAuth
  '/auth.v2.AuthService/GetOAuthUrl',
  '/auth.v2.AuthService/ExchangeOAuthCode',
};

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
  /// immediately. Mirrors the HTTP `AuthenticationMiddleware`.
  final Future<AccessCredentials?> Function(String usedAccessToken)? refresh;

  /// Callback when authentication fails (logout). Called when there is no token,
  /// on `PERMISSION_DENIED`, or on `UNAUTHENTICATED` that refresh could not recover.
  final VoidCallback? onAuthError;

  final Set<String> unauthenticatedPaths;

  @override
  GrpcMiddlewareHandler call(GrpcMiddlewareHandler invoker) => (path, metadata) async {
    if (unauthenticatedPaths.contains(path)) return _public(invoker, path, metadata);

    final credentials = await _resolveCredentials();
    try {
      await invoker(path, _withToken(metadata, credentials));
    } on GrpcError catch (e) {
      // Auth-error policy on the (unary) data path (mirrors HTTP):
      // - UNAUTHENTICATED (401) → token invalid/expired: refresh once + retry once; log out only
      //   if there's no refresh or it definitively fails (a 2nd 401 = broken session).
      // - PERMISSION_DENIED (403) → authenticated but not allowed: do NOT refresh/retry/log out.
      if (e.code == StatusCode.unauthenticated && refresh != null) {
        final fresh = await refresh!(credentials.accessToken.token);
        // [refresh] contract: rotated creds on success; `null` on a definitive rejection (repo
        // already logged out); or it throws on a transient failure (session intact) — which
        // propagates out of here WITHOUT calling [onAuthError], so a network blip never logs out.
        if (fresh != null && fresh.accessToken.token.isNotEmpty) {
          try {
            await invoker(path, _withToken(metadata, fresh)); // retry once with the rotated token
            return;
          } on GrpcError catch (err) {
            if (err.code == StatusCode.unauthenticated) onAuthError?.call(); // fresh token still 401 → broken session
            rethrow;
          }
        }
        // Definitive rejection (repo already cleared creds + ended the session) — log out.
        onAuthError?.call();
        rethrow;
      }
      // 401 with no refresh available → can't recover → log out. 403 / non-auth codes → surface as-is.
      if (e.code == StatusCode.unauthenticated) onAuthError?.call();
      rethrow;
    }
  };

  @override
  GrpcMiddlewareHandler callStreaming(GrpcMiddlewareHandler invoker) => (path, metadata) async {
    if (unauthenticatedPaths.contains(path)) return _public(invoker, path, metadata);

    final credentials = await _resolveCredentials();
    // Server-streaming RPCs (e.g. listUsers): the request `Stream` can't be replayed, so we attach
    // the token and surface errors WITHOUT reactive refresh-retry (mirrors GrpcRetryMiddleware,
    // which excludes streaming). The proactive getToken() keeps the token valid at call start; an
    // UNAUTHENTICATED logs out and propagates rather than re-invoking a consumed stream.
    try {
      await invoker(path, _withToken(metadata, credentials));
    } on GrpcError catch (e) {
      if (e.code == StatusCode.unauthenticated) onAuthError?.call();
      rethrow;
    }
  };

  /// Public endpoints (sign-in / RefreshTokens / OAuth): no token, no refresh-retry, but still log
  /// out on an auth-code error (e.g. an invalid/expired refresh token).
  Future<void> _public(GrpcMiddlewareHandler invoker, String path, Map<String, String> metadata) async {
    try {
      await invoker(path, metadata);
    } on GrpcError catch (e) {
      if (_isAuthError(e)) onAuthError?.call();
      rethrow;
    }
  }

  /// Resolves the current credentials.
  ///
  /// Logout is gated on a *definitively absent* token only (`null`/empty). A transient failure to
  /// resolve credentials (e.g. a secure-storage hiccup) propagates as-is — failing this one call
  /// WITHOUT logging out, since the session may still be valid and a later request can retry (A3).
  Future<AccessCredentials> _resolveCredentials() async {
    final c = await getToken();
    if (c == null || c.accessToken.token.isEmpty) {
      onAuthError?.call();
      throw const GrpcError.unauthenticated('Authentication token is null or empty');
    }
    return c;
  }

  /// Builds a fresh metadata copy (the original may be unmodifiable) carrying only the access
  /// token. The refresh token is sent solely to the RefreshTokens RPC, never on every request.
  Map<String, String> _withToken(Map<String, String> metadata, AccessCredentials c) =>
      Map<String, String>.of(metadata)..[_kAuthorizationKey] = '$_kBearerScheme ${c.accessToken.token}';

  /// Whether [e] is an auth-code error. Used only for the public (sign-in / RefreshTokens) path,
  /// where such an error means a rejected refresh token ⇒ log out. On the authenticated data path,
  /// logout is gated on `unauthenticated` alone (403 / PERMISSION_DENIED is surfaced, not logged out).
  static bool _isAuthError(GrpcError e) =>
      e.code == StatusCode.unauthenticated || e.code == StatusCode.permissionDenied;
}
