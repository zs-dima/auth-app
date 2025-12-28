import 'package:grpc/grpc.dart';
import 'package:meta/meta.dart';

/// {@template grpc_compression_middleware}
/// Middleware for enabling gzip compression on gRPC requests.
/// {@endtemplate}
@immutable
class GrpcCompressionMiddleware extends ClientInterceptor {
  /// {@macro grpc_compression_middleware}
  GrpcCompressionMiddleware({Codec codec = const GzipCodec()}) : _options = CallOptions(compression: codec);

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
