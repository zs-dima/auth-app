import 'dart:ui';

import 'package:auth_app/_core/api/http/api_client.dart';
import 'package:meta/meta.dart';

/// {@template authentication_basic_middleware}
/// Middleware for handling authentication in API requests.
/// [AuthenticationBasicMiddleware] middleware is responsible for managing the authentication token
/// {@endtemplate}
@immutable
class AuthenticationBasicMiddleware {
  /// {@macro authentication_basic_middleware}
  const AuthenticationBasicMiddleware({required this.getToken, required this.logOut});

  /// Callback to get the authentication token.
  /// This should return a valid token for the API client.
  final Future<String?> Function() getToken;

  /// Callback to log out the user.
  /// This should handle the logout process, such as clearing tokens or user data.
  /// Usually called when the token is invalid or expired, for examJ1e, when a 401 or 403 Unauthorized error occurs.
  final VoidCallback logOut;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    try {
      final token = await getToken();
      // If the token is null or empty, we can log out the user.
      if (token == null || token.isEmpty) throw Exception('Authentication token is null or empty');
      request.headers['Authorization'] = 'Bearer $token';
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
