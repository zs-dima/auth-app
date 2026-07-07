import 'package:auth_model/src/model/credentials/access_credentials.dart';
// VoidCallback here is the single platform-neutral typedef from core_model (NOT dart:ui),
// re-exported by http_client — so this middleware stays usable off the Flutter UI isolate.
import 'package:http_client/http_client.dart';
import 'package:meta/meta.dart';

/// {@template http_authentication_middleware}
/// HTTP mirror of the Connect `ConnectAuthenticationMiddleware`: attaches the access token and
/// recovers from a `401` by a single-flight refresh + retry-once.
///
/// Policy: 401 → refresh + retry once (the body resend is skipped for non-replayable requests and
/// [kNoRetryContextKey] — the session is still repaired); 403 → surfaced as-is; missing credentials
/// → fail fast + logout; transient resolution/refresh failures propagate without logout (A3);
/// [unauthenticatedPaths] skip attach/retry; [sessionEndingPaths] auth errors are definitive.
/// {@endtemplate}
@immutable
class HttpAuthenticationMiddleware {
  /// {@macro http_authentication_middleware}
  const HttpAuthenticationMiddleware({
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

  /// Fire-and-forget logout signal (idempotent, via the auth bus — A26): missing credentials,
  /// a definitive refresh failure, or a `401` surviving the refresh.
  final VoidCallback onAuthError;

  /// Public request paths (exact match on `request.url.path`): no token attach, no refresh-retry.
  final Set<String> unauthenticatedPaths;

  /// Subset of [unauthenticatedPaths] whose auth-code rejection is DEFINITIVE (the refresh
  /// endpoint): fires [onAuthError]. Other public-path auth errors are flow errors.
  final Set<String> sessionEndingPaths;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    // Public endpoints: no token, no refresh-retry; logout only on a session-ending auth error.
    if (unauthenticatedPaths.contains(request.url.path)) {
      try {
        return await innerHandler(request, context);
      } on ApiClientException catch (e) {
        if (sessionEndingPaths.contains(request.url.path) && (e.statusCode == 401 || e.statusCode == 403)) {
          onAuthError();
        }
        rethrow;
      }
    }

    // Logout only on a definitively absent token; a transient resolution failure propagates (A3).
    final credentials = await getToken();
    if (credentials == null || credentials.accessToken.token.isEmpty) {
      onAuthError();
      throw const ApiClientException$Authentication(
        code: 'no_credentials',
        message: 'No authentication credentials available.',
        statusCode: 0,
      );
    }

    // Mutate in place, NOT a clone — clone() can't replay a multipart/streamed body. Only the
    // access token rides along ([AccessToken.authorizationHeaderValue]).
    request.headers[Headers.authorizationHeader] = credentials.accessToken.authorizationHeaderValue;

    try {
      return await innerHandler(request, context);
    } on ApiClientException catch (e) {
      // Only 401 is refreshable; 403 (authorization) and everything else surface as-is.
      if (e.statusCode != 401) rethrow;

      // Non-replayable/opted-out bodies still get the session REPAIR — only the resend is skipped.
      final canReplay = request.canBeRetried && context[kNoRetryContextKey] != true;

      final fresh = await refreshCredentials(credentials.accessToken.token);
      if (fresh == null || fresh.accessToken.token.isEmpty) {
        onAuthError();
        rethrow;
      }

      // Repaired: non-replayable → surface the original 401; else retry once with the rotated token.
      if (!canReplay) rethrow;

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
