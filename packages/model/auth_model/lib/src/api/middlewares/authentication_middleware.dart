import 'dart:io';
import 'dart:ui';

import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_model/grpc_model.dart';
import 'package:meta/meta.dart';

extension HttpHeadersEx on HttpHeaders {
  static const bearer = 'Bearer';
  static const refreshToken = 'Refresh-Token';
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
    this.onAuthError,
    this.unauthenticatedPaths = const <String>{},
  });

  /// Callback to get the authentication token.
  /// This should return a valid token for the API client.
  final Future<AccessCredentials?> Function() getToken;

  /// Callback when authentication fails.
  /// This should handle the logout process, such as clearing tokens or user data.
  /// Usually called when the token is invalid or expired, for example, when a 401 or 403 Unauthorized error occurs.
  final VoidCallback? onAuthError;

  final Set<String> unauthenticatedPaths;

  @override
  ApiClientHandler call(ApiClientHandler invoker) => (path, metadata) async {
    // Create a mutable copy of the metadata map since the original may be unmodifiable.
    final mutableMetadata = Map<String, String>.of(metadata);
    if (!unauthenticatedPaths.contains(path)) {
      try {
        final credentials = await getToken();
        // If the token is null or empty, we can log out the user.
        if (credentials == null || credentials.accessToken.token.isEmpty)
          throw const GrpcError.unauthenticated('Authentication token is null or empty');

        mutableMetadata[HttpHeaders.authorizationHeader] = '${HttpHeadersEx.bearer} ${credentials.accessToken.token}';
        mutableMetadata[HttpHeadersEx.refreshToken] = credentials.refreshToken;
      } on Object {
        onAuthError?.call();
        rethrow;
      }
    }

    // Call the inner handler with the modified request, which now includes the Authorization header.
    // If the request is successful, it will return the response.
    // If an ApiClientException occurs, we can handle it accordingly and check if we need to log out the user.
    try {
      await invoker(path, mutableMetadata);
    } on GrpcError catch (e) {
      // If the response indicates an authentication error {401, 403}, we can log out the user.
      const authErrorCodes = <int>{StatusCode.unauthenticated, StatusCode.permissionDenied};
      if (authErrorCodes.contains(e.code)) onAuthError?.call();
      rethrow;
    }
  };
}
