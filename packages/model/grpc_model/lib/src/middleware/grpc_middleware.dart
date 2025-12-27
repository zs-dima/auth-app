import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:meta/meta.dart';

/// Context for gRPC middleware, allowing middlewares to share data.
typedef GrpcContext = Map<String, Object?>;

/// A gRPC request wrapper that encapsulates all request information.
@immutable
class GrpcRequest<Q, R> {
  const GrpcRequest({required this.method, required this.requests, required this.options});

  /// The gRPC method being called.
  final ClientMethod<Q, R> method;

  /// The request stream (for unary calls, this is a single-element stream).
  final Stream<Q> requests;

  /// Call options including timeout, metadata, etc.
  final CallOptions options;

  /// Creates a copy of this request with the given fields replaced.
  GrpcRequest<Q, R> copyWith({ClientMethod<Q, R>? method, Stream<Q>? requests, CallOptions? options}) =>
      GrpcRequest<Q, R>(
        method: method ?? this.method,
        requests: requests ?? this.requests,
        options: options ?? this.options,
      );
}

/// A gRPC response wrapper.
@immutable
class GrpcResponse<R> {
  const GrpcResponse({required this.data, this.headers = const {}, this.trailers = const {}});

  /// The response data.
  final R data;

  /// Response headers from the server.
  final Map<String, String> headers;

  /// Response trailers from the server.
  final Map<String, String> trailers;
}

/// Handler function type for gRPC middleware chain.
typedef GrpcHandler<Q, R> = Future<GrpcResponse<R>> Function(GrpcRequest<Q, R> request, GrpcContext context);

/// Callback type for gRPC metadata providers (compatible with gRPC's MetadataProvider).
typedef GrpcMetadataProvider = Future<void> Function(Map<String, String> metadata, String uri);

/// Abstract base class for gRPC middlewares.
///
/// Middlewares wrap the handler chain, processing requests and responses.
/// Similar to HTTP middleware pattern:
/// ```dart
/// GrpcHandler call(GrpcHandler next) => (request, context) async {
///   // Pre-processing
///   final response = await next(request, context);
///   // Post-processing
///   return response;
/// };
/// ```
abstract class GrpcMiddlewareBase {
  const GrpcMiddlewareBase();

  /// Optional metadata provider for streaming calls.
  ///
  /// Override this to provide metadata for [ResponseFuture]/[ResponseStream]
  /// calls that use gRPC's built-in metadata provider mechanism.
  GrpcMetadataProvider? get metadataProvider => null;

  /// Applies this middleware to the handler chain.
  GrpcHandler<Q, R> call<Q, R>(GrpcHandler<Q, R> next);
}

/// Exception thrown by gRPC client operations.
@immutable
class GrpcClientException implements Exception {
  const GrpcClientException({required this.code, required this.message, this.statusCode, this.error, this.details});

  /// Creates an exception from a [GrpcError].
  factory GrpcClientException.fromGrpcError(GrpcError error) => GrpcClientException(
    code: error.codeName,
    message: error.message ?? 'Unknown gRPC error',
    statusCode: error.code,
    error: error,
    details: error.details,
  );

  final String code;
  final String message;
  final int? statusCode;
  final Object? error;
  final Object? details;

  @override
  String toString() => 'GrpcClientException($code: $message)';
}

/// Authentication-specific gRPC exception.
class GrpcClientException$Authentication extends GrpcClientException {
  const GrpcClientException$Authentication({
    required super.code,
    required super.message,
    super.statusCode,
    super.error,
    super.details,
  });
}

/// Timeout-specific gRPC exception.
class GrpcClientException$Timeout extends GrpcClientException {
  const GrpcClientException$Timeout({
    required super.code,
    required super.message,
    required this.duration,
    super.statusCode,
    super.error,
    super.details,
  });

  final Duration duration;
}

/// Network-specific gRPC exception.
class GrpcClientException$Network extends GrpcClientException {
  const GrpcClientException$Network({
    required super.code,
    required super.message,
    super.statusCode,
    super.error,
    super.details,
  });
}
