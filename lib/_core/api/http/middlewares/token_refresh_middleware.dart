import 'package:auth_app/_core/api/http/api_client.dart';
import 'package:auth_app/_core/api/http/middlewares/authentication_middleware.dart';
import 'package:auth_model/auth_model.dart';
import 'package:meta/meta.dart';

/// Context key marking that this request already attempted a token refresh, so a
/// second `401` does not loop forever.
const kDidRefreshContextKey = '__did_refresh';

/// {@template token_refresh_middleware}
/// Refreshes the access token on a `401` and retries the original request once.
///
/// Must be placed **outside** [AuthenticationMiddleware] in the pipeline so that
/// the retry re-runs authentication and attaches the freshly rotated token.
///
/// Concurrency: when many requests get `401` at the same time, every one calls
/// [refreshCredentials], but the repository performs the actual network refresh
/// only once (single-flight) — the rest reuse the rotated token. If the refresh
/// fails, [refreshCredentials] returns `null` (and triggers logout), so every
/// waiting request fails fast with its original error instead of retrying.
/// {@endtemplate}
@immutable
class TokenRefreshMiddleware {
  /// {@macro token_refresh_middleware}
  const TokenRefreshMiddleware({required this.refreshCredentials});

  /// Forces a single-flight token refresh for the access token that was rejected.
  /// Returns the new credentials, or `null` when the refresh failed.
  final Future<AccessCredentials?> Function(String usedAccessToken) refreshCredentials;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    try {
      return await innerHandler(request, context);
    } on ApiClientException catch (e) {
      // Only unauthorized errors are recoverable, and only once per request. Skip
      // requests that opted out of retry, or whose body can't be replayed (multipart /
      // streamed — a finalized body can't be re-sent and clone() can't rebuild it).
      if (e.statusCode != 401 ||
          context[kDidRefreshContextKey] == true ||
          context[kNoRetryContextKey] == true ||
          !request.canBeRetried)
        rethrow;
      context[kDidRefreshContextKey] = true;

      final usedToken = switch (context[kAccessTokenContextKey]) {
        final String token => token,
        _ => '',
      };

      // Single-flight refresh in the repository. Contract: returns rotated creds on success;
      // `null` on a definitive rejection (repository already logged out); or throws on a
      // transient failure (session intact) — which propagates here, surfacing the error without
      // logging out so a later request can retry.
      final fresh = await refreshCredentials(usedToken);

      // Definitive rejection (logout already triggered by the repository) — fail fast.
      if (fresh == null) rethrow;

      // Retry once with a fresh request: the original was already finalized by the
      // first send, and re-sending a finalized http request throws StateError.
      // AuthenticationMiddleware (inner) re-attaches the new token onto the clone.
      return innerHandler(request.clone(), context);
    }
  };
}
