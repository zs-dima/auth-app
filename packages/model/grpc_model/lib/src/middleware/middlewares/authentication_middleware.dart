import 'package:grpc/grpc.dart';
import 'package:grpc_model/src/middleware/grpc_middleware.dart';
import 'package:meta/meta.dart';

/// Callback type for handling authentication errors.
typedef AuthenticationErrorHandler = void Function();

/// {@template grpc_authentication_middleware}
/// Middleware for handling authentication in gRPC requests.
///
/// Adds Bearer token authentication to outgoing requests and handles
/// authentication errors (401/403 responses).
/// {@endtemplate}
@immutable
class GrpcAuthenticationMiddleware extends GrpcMiddlewareBase {
  /// {@macro grpc_authentication_middleware}
  const GrpcAuthenticationMiddleware({
    required this.getToken,
    this.onAuthenticationError,
    this.allowAnonymous = false,
  });

  /// Callback to get the authentication token.
  ///
  /// Should return a valid Bearer token for the API client.
  /// If null or empty is returned and [allowAnonymous] is false,
  /// the request will be rejected with an authentication error.
  final Future<String?> Function() getToken;

  /// Callback invoked when an authentication error occurs.
  ///
  /// This is called when:
  /// - Token retrieval fails
  /// - Token is null/empty and anonymous is not allowed
  /// - Server responds with 401 (Unauthenticated) or 403 (Permission Denied)
  final AuthenticationErrorHandler? onAuthenticationError;

  /// Whether to allow requests without authentication.
  ///
  /// If true, requests will proceed even if no token is available.
  /// If false, requests without a token will fail immediately.
  final bool allowAnonymous;

  @override
  GrpcMetadataProvider get metadataProvider => (metadata, _) async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      metadata['authorization'] = 'Bearer $token';
    }
  };

  @override
  GrpcHandler<Q, R> call<Q, R>(GrpcHandler<Q, R> next) => (request, context) async {
    try {
      final token = await getToken();

      // Validate token
      if (token == null || token.isEmpty) {
        if (!allowAnonymous) {
          onAuthenticationError?.call();
          throw const GrpcClientException$Authentication(
            code: 'no_auth_token',
            message: 'Authentication token is null or empty',
            statusCode: StatusCode.unauthenticated,
          );
        }
        // Anonymous access allowed, proceed without token
        return await next(request, context);
      }

      // Add authorization header
      final updatedOptions = request.options.mergedWith(
        CallOptions(metadata: {'authorization': 'Bearer $token'}),
      );

      return await next(request.copyWith(options: updatedOptions), context);
    } on GrpcClientException catch (e) {
      if (_isAuthenticationError(e.statusCode)) onAuthenticationError?.call();
      rethrow;
    } on GrpcError catch (e) {
      if (_isAuthenticationError(e.code)) onAuthenticationError?.call();
      rethrow;
    }
  };

  bool _isAuthenticationError(int? statusCode) =>
      statusCode == StatusCode.unauthenticated || statusCode == StatusCode.permissionDenied;
}
