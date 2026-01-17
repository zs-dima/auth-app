import 'package:grpc/grpc.dart';
import 'package:meta/meta.dart';

/// {@template grpc_metadata_middleware}
/// Middleware for adding metadata to gRPC requests.
/// {@endtemplate}
@immutable
class GrpcMetadataMiddleware extends ClientInterceptor {
  /// {@macro grpc_metadata_middleware}
  GrpcMetadataMiddleware({required Map<String, String> metadata})
    : _options = CallOptions(metadata: Map.unmodifiable(metadata));

  final CallOptions _options;

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) => invoker(method, request, options.mergedWith(_options));

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
  ) => invoker(method, requests, options.mergedWith(_options));
}
