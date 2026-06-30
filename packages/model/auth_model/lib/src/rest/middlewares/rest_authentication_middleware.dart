import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:meta/meta.dart';
// VoidCallback here is the single platform-neutral typedef from core_model (NOT dart:ui),
// re-exported by rest_client — so this middleware stays usable off the Flutter UI isolate.
import 'package:rest_client/rest_client.dart';

/// {@template rest_authentication_middleware}
/// Attaches the access token to each request and transparently recovers from a `401` by
/// refreshing once and retrying — both concerns in one middleware (mirroring the gRPC
/// [GrpcAuthenticationMiddleware]), so there is no cross-middleware context or ordering coupling.
///
/// Failure policy (HTTP semantics / OAuth2):
/// - **401** (token invalid/expired) → single-flight [refreshCredentials] + retry **once** with
///   the rotated token (skipped when the body can't be replayed or the request opts out via
///   [kNoRetryContextKey]). Log out only when refresh fails definitively or a 2nd `401` survives.
/// - **403** (authenticated but not allowed) → surfaced as-is: no refresh, no retry, no logout.
/// - Missing/empty credentials → log out and fail fast. A *transient* failure to resolve
///   credentials (e.g. a secure-storage hiccup) propagates as-is WITHOUT logging out (A3).
/// - Paths in [unauthenticatedPaths] (sign-in / refresh / public) skip token-attach and
///   refresh-retry, but still log out on a `401`/`403` auth-code error.
/// {@endtemplate}
@immutable
class RestAuthenticationMiddleware {
  /// {@macro rest_authentication_middleware}
  const RestAuthenticationMiddleware({
    required this.getToken,
    required this.refreshCredentials,
    required this.onAuthError,
    this.unauthenticatedPaths = const <String>{},
  });

  /// Resolves the current credentials. Expected to proactively refresh tokens that are about to
  /// expire (single-flight in the repository), so the common path is cheap/cached.
  final Future<AccessCredentials?> Function() getToken;

  /// Forces a single-flight refresh for the access token that was just rejected with `401`.
  /// Contract: returns the rotated credentials on success; `null` on a definitive rejection
  /// (the repository has already cleared the session); or **throws** on a transient failure
  /// (session intact) — which propagates without logging out so a later request can retry.
  final Future<AccessCredentials?> Function(String usedAccessToken) refreshCredentials;

  /// Callback when authentication fails (logout). Invoked when credentials are missing, refresh
  /// fails definitively, or a `401` survives a refresh. Mirrors the gRPC `GrpcAuthenticationMiddleware`.
  final VoidCallback onAuthError;

  /// Request URL paths (exact match on `request.url.path`) that are public — sign-in / refresh /
  /// OAuth: no token is attached and a `401` does not trigger a refresh-retry. Mirrors the gRPC
  /// [GrpcAuthenticationMiddleware.unauthenticatedPaths].
  final Set<String> unauthenticatedPaths;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    // Public endpoints (sign-in / refresh / OAuth): no token, no refresh-retry, but still log out
    // on an auth-code error (e.g. an invalid/expired refresh token).
    if (unauthenticatedPaths.contains(request.url.path)) {
      try {
        return await innerHandler(request, context);
      } on ApiClientException catch (e) {
        if (e.statusCode == 401 || e.statusCode == 403) onAuthError();
        rethrow;
      }
    }

    // Resolve the current credentials. [getToken] proactively refreshes tokens about to expire.
    // Logout is gated on a *definitively absent* token only (`null`/empty). A transient failure to
    // resolve credentials (e.g. a secure-storage hiccup) propagates as-is — failing this one call
    // WITHOUT logging out, since the session may still be valid and a later request can retry (A3).
    final credentials = await getToken();
    if (credentials == null || credentials.accessToken.token.isEmpty) {
      onAuthError();
      throw const ApiClientException$Authentication(
        code: 'no_credentials',
        message: 'No authentication credentials available.',
        statusCode: 0,
      );
    }

    // Attach on the original request (mutate in place), NOT a clone: clone() rebuilds a plain
    // Request and can't replay a multipart/streamed body, so cloning here would drop the upload.
    // Only the access token rides along; the refresh token is sent solely to the refresh endpoint.
    // The scheme comes from the token itself ([AccessToken.type], usually `Bearer`) — the single
    // transport-neutral source of truth, mirroring the gRPC middleware.
    request.headers[Headers.authorizationHeader] = credentials.accessToken.authorizationHeaderValue;

    try {
      return await innerHandler(request, context);
    } on ApiClientException catch (e) {
      // Only 401 is refreshable. 403 (authorization) and everything else surface as-is; a body
      // that can't be replayed (multipart / streamed) can't be retried.
      if (e.statusCode != 401 || !request.canBeRetried || context[kNoRetryContextKey] == true) rethrow;

      // Single-flight refresh: rotated creds on success; `null` ⇒ definitive (session already
      // ended); throws ⇒ transient (propagates here without logout so a later request retries).
      final fresh = await refreshCredentials(credentials.accessToken.token);
      if (fresh == null || fresh.accessToken.token.isEmpty) {
        onAuthError();
        rethrow;
      }

      // Retry once with a fresh clone carrying the rotated token (the original was finalized).
      try {
        return await innerHandler(
          request.clone(headers: <String, String>{
            Headers.authorizationHeader: fresh.accessToken.authorizationHeaderValue,
          }),
          context,
        );
      } on ApiClientException catch (err) {
        if (err.statusCode == 401) onAuthError(); // a fresh token still rejected ⇒ broken session
        rethrow;
      }
    }
  };
}
