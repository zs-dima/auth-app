import 'package:meta/meta.dart';
import 'package:rest_client/src/api_client.dart';
import 'package:rest_client/src/headers.dart';

// Platform-neutral typedef (NOT dart:ui) so this "portable" package stays web/server-safe (A1) —
// mirrors auth_model's GrpcAuthenticationMiddleware, which uses the same neutral callback for logout.
typedef VoidCallback = void Function();

/// {@template bearer_authentication_middleware}
/// Minimal Bearer-token auth middleware: attaches `Authorization: Bearer <token>` to every request
/// and logs out when the token is missing or the server replies `401`/`403`. It performs **no**
/// token refresh and has **no** public-path exemptions — for the full refresh / retry-once /
/// single-flight flow use `auth_model`'s `RestAuthenticationMiddleware`.
///
/// Named after the **Bearer** scheme it implements (RFC 6750) — NOT HTTP Basic auth. See the
/// deprecated `AuthenticationBasicMiddleware` alias kept for backward compatibility.
/// {@endtemplate}
@immutable
class BearerAuthenticationMiddleware {
  /// {@macro bearer_authentication_middleware}
  const BearerAuthenticationMiddleware({required this.getToken, required this.logOut});

  /// Resolves the current bearer token (the raw token string, without a scheme). A `null`/empty
  /// result is treated as "not authenticated" → [logOut] + a typed [ApiClientException$Authentication].
  final Future<String?> Function() getToken;

  /// Invoked on logout: when the token is missing/unresolvable, or the server replies `401`/`403`.
  final VoidCallback logOut;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw const ApiClientException$Authentication(
          code: 'no_credentials',
          message: 'No authentication token available.',
          statusCode: 0,
        );
      }
      // Header key + scheme come from the shared [Headers] constants (single source of truth),
      // mirroring auth_model's RestAuthenticationMiddleware.
      request.headers[Headers.authorizationHeader] = '${Headers.bearerScheme} $token';
    } on Object {
      // Missing token or a token-resolution failure → log out and surface the error.
      logOut();
      rethrow;
    }

    try {
      return await innerHandler(request, context);
    } on ApiClientException catch (e) {
      const logoutStatusCodes = <int>{401, 403};
      if (logoutStatusCodes.contains(e.statusCode)) logOut();
      rethrow;
    }
  };
}
