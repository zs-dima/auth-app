import 'package:grpc/grpc.dart';
import 'package:grpc_model/src/middleware/grpc_middleware.dart';
import 'package:meta/meta.dart';

/// {@template grpc_metadata_middleware}
/// Middleware for adding metadata headers to gRPC requests.
///
/// Automatically adds predefined headers like platform info, app version,
/// locale, etc. to every request.
/// {@endtemplate}
@immutable
class GrpcMetadataMiddleware extends GrpcMiddlewareBase {
  /// {@macro grpc_metadata_middleware}
  const GrpcMetadataMiddleware({required this.metadata});

  /// Creates a metadata middleware with common app metadata.
  factory GrpcMetadataMiddleware.fromAppInfo({
    required String appName,
    required String appVersion,
    required String environment,
    required String platform,
    required String locale,
    String? deviceId,
    String? operatingSystem,
    bool isRelease = false,
  }) => GrpcMetadataMiddleware(
    metadata: <String, String>{
      'x-app-name': appName,
      'x-app-version': appVersion,
      'x-environment': environment,
      'x-platform': platform,
      'x-locale': locale,
      'x-is-release': isRelease.toString(),
      if (deviceId != null) 'x-device-id': deviceId,
      if (operatingSystem != null) 'x-operating-system': operatingSystem,
    },
  );

  /// Static metadata to add to every request.
  final Map<String, String> metadata;

  @override
  GrpcMetadataProvider get metadataProvider =>
      (meta, _) async => meta.addAll(metadata);

  @override
  GrpcHandler<Q, R> call<Q, R>(GrpcHandler<Q, R> next) => (request, context) {
    final updatedOptions = request.options.mergedWith(CallOptions(metadata: metadata));
    return next(request.copyWith(options: updatedOptions), context);
  };
}

/// {@template grpc_dynamic_metadata_middleware}
/// Middleware for adding dynamic metadata to gRPC requests.
///
/// Unlike [GrpcMetadataMiddleware], this evaluates metadata at request time,
/// allowing for dynamic values like timestamps or request IDs.
/// {@endtemplate}
@immutable
class GrpcDynamicMetadataMiddleware extends GrpcMiddlewareBase {
  /// {@macro grpc_dynamic_metadata_middleware}
  const GrpcDynamicMetadataMiddleware({required this.getMetadata});

  /// Provider function that returns metadata for each request.
  final Map<String, String> Function() getMetadata;

  @override
  GrpcMetadataProvider get metadataProvider =>
      (meta, _) async => meta.addAll(getMetadata());

  @override
  GrpcHandler<Q, R> call<Q, R>(GrpcHandler<Q, R> next) => (request, context) {
    final dynamicMetadata = getMetadata();
    final updatedOptions = request.options.mergedWith(CallOptions(metadata: dynamicMetadata));
    return next(request.copyWith(options: updatedOptions), context);
  };
}

/// {@template grpc_correlation_id_middleware}
/// Middleware that adds a correlation ID to each request for tracing.
///
/// If a correlation ID is already present in the context, it will be used.
/// Otherwise, a new UUID will be generated.
/// {@endtemplate}
@immutable
class GrpcCorrelationIdMiddleware extends GrpcMiddlewareBase {
  /// {@macro grpc_correlation_id_middleware}
  const GrpcCorrelationIdMiddleware({
    this.headerName = 'x-correlation-id',
    this.idGenerator,
  });

  /// The header name for the correlation ID.
  final String headerName;

  /// Custom ID generator. If null, uses a simple timestamp-based ID.
  final String Function()? idGenerator;

  @override
  GrpcHandler<Q, R> call<Q, R>(GrpcHandler<Q, R> next) => (request, context) {
    // Use existing correlation ID from context or generate new one
    final correlationId = context['correlation_id']?.toString() ?? _generateId();

    // Store in context for downstream use
    context['correlation_id'] = correlationId;

    final updatedOptions = request.options.mergedWith(
      CallOptions(metadata: {headerName: correlationId}),
    );

    return next(request.copyWith(options: updatedOptions), context);
  };

  String _generateId() {
    if (idGenerator != null) return idGenerator!();
    // Simple fallback ID generation
    return '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecondsSinceEpoch % 1000}';
  }
}
