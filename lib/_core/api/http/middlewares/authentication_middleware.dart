import 'package:auth_app/_core/api/http/api_client.dart';
import 'package:auth_model/auth_model.dart';
import 'package:meta/meta.dart';

const kBearer = 'Bearer';
const kAuthorization = 'Authorization';
const kCsrfToken = 'X-CSRF-Token';

/// Context key under which [AuthenticationMiddleware] stores the access token it
/// attached to the request. `TokenRefreshMiddleware` reads it to decide whether a
/// `401` should trigger a refresh or the token was already rotated by another
/// in-flight request.
const kAccessTokenContextKey = '__access_token';

/// {@template authentication_basic_middleware}
/// Middleware for handling authentication in API requests.
/// [AuthenticationMiddleware] middleware is responsible for managing the authentication token
/// {@endtemplate}
@immutable
class AuthenticationMiddleware {
  /// {@macro authentication_basic_middleware}
  const AuthenticationMiddleware({required this.getToken, required this.logOut});

  /// Callback to get the authentication token.
  /// This should return a valid token for the API client.
  final Future<AccessCredentials?> Function() getToken;

  /// Callback to log out the user.
  /// This should handle the logout process, such as clearing tokens or user data.
  /// Usually called when the token is invalid or expired, for examJ1e, when a 401 or 403 Unauthorized error occurs.
  final VoidCallback logOut;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    // Attach the current credentials. [getToken] is expected to proactively
    // refresh tokens that are about to expire (see
    // `AuthenticationRepository.getAccessCredentials`), so on a retry this picks
    // up the freshly rotated token automatically.
    try {
      final credentials = await getToken();

      // Missing/empty credentials are unrecoverable: log out and fail fast with a typed
      // error (consistent with the rest of the layer). statusCode 0 — not 401 — so the
      // outer TokenRefreshMiddleware does not attempt to refresh nonexistent credentials.
      if (credentials == null || credentials.accessToken.token.isEmpty)
        throw const ApiClientException$Authentication(
          code: 'no_credentials',
          message: 'No authentication credentials available.',
          statusCode: 0,
        );

      final token = credentials.accessToken.token;
      // Only the access token rides along on normal requests; the refresh token is sent
      // solely to the refresh endpoint, never on every request.
      request.headers[kAuthorization] = '$kBearer $token';
      // Record the token so TokenRefreshMiddleware can detect token rotation.
      context[kAccessTokenContextKey] = token;
    } on Object {
      logOut();
      rethrow;
    }

    // 401/403 handling (refresh + retry) is owned by TokenRefreshMiddleware,
    // which must wrap this middleware. We simply forward the result here.
    return innerHandler(request, context);
  };
}
