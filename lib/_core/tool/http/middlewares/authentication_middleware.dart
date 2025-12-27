import 'package:auth_app/_core/tool/http/api_client.dart';
import 'package:auth_model/auth_model.dart';
import 'package:meta/meta.dart';

const kBearer = 'Bearer';
const kAuthorization = 'Authorization';
const kCsrfToken = 'X-CSRF-Token';

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
    try {
      final credentials = await getToken();

      // If the token is null or empty, we can log out the user.
      if (credentials == null || credentials.accessToken.token.isEmpty)
        throw Exception('Authentication token is null or empty');
      request.headers[kAuthorization] = '$kBearer ${credentials.accessToken.token}';
      request.headers[kCsrfToken] = credentials.refreshToken;
    } on Object {
      // If an error occurs, we can log it or handle it as needed.
      // For example, if the token is invalid or expired, we can call the logout function.
      logOut();
      rethrow;
    }

    // Call the inner handler with the modified request, which now includes the Authorization header.
    // If the request is successful, it will return the response.
    // If an ApiClientException occurs, we can handle it accordingly and check if we need to log out the user.
    try {
      return await innerHandler(request, context);
    } on ApiClientException catch (e) {
      // If the response indicates an authentication error, we can log out the user.
      const logoutStatusCodes = <int>{401, 403};
      if (logoutStatusCodes.contains(e.statusCode)) logOut();
      rethrow;
    }
  };
}

// /// {@template authentication_middleware}
// /// Middleware for adding authentication headers to API requests.
// /// {@endtemplate}
// @immutable
// class AuthenticationMiddleware {
//   /// {@macro authentication_middleware}
//   const AuthenticationMiddleware({required this.credentialsManager});

//   /// Credentials manager for handling authentication tokens
//   final CredentialsCallbacks credentialsManager;

//   ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
//     final credentials = await credentialsManager.getAccessCredentials();

//     if (credentials?.accessToken != null) {
//       request.headers['Authorization'] = 'Bearer ${credentials!.accessToken.token}';
//       request.headers['X-CSRF-Token'] = credentials.refreshToken;
//     } else if (!credentialsManager.allowAnonymous) {
//       credentialsManager.authHandler?.handleAuthenticationError();
//       throw const ApiClientException$Authentication(
//         code: 'no_auth_credentials',
//         statusCode: 401,
//         message: 'No authentication credentials available',
//       );
//     }

//     return innerHandler(request, context);
//   };
// }
