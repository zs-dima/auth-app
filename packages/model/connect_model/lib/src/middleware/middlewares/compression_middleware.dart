// Compression on the Connect transport is a **Transport-level option**, not an interceptor:
// `sendCompression:` / `acceptCompressions:` on `createConnectTransport` (`Compression` interface
// from `package:connectrpc`; a gzip implementation — `GzipCompression` — ships with connectrpc
// for IO platforms). Response DECODING is on by default via the platform
// `defaultAcceptCompressions` (gzip on IO — parity with the grpc-era `CodecRegistry`, which let
// the server compress responses). SEND-side compression stays unwired by default, matching the
// grpc-era setup where this compression interceptor existed but was never registered — enable
// deliberately per deployment.
//
// The grpc-era interceptor is preserved below for reference (standby):
//
// ```dart
// /// {@template grpc_compression_middleware}
// /// Middleware for enabling gzip compression on gRPC requests.
// /// {@endtemplate}
// @immutable
// class GrpcCompressionMiddleware extends ClientInterceptor {
//   /// {@macro grpc_compression_middleware}
//   GrpcCompressionMiddleware({Codec codec = const GzipCodec()}) : _options = CallOptions(compression: codec);
//
//   final CallOptions _options;
//
//   @override
//   ResponseFuture<R> interceptUnary<Q, R>(
//     ClientMethod<Q, R> method,
//     Q request,
//     CallOptions options,
//     ClientUnaryInvoker<Q, R> invoker,
//   ) => invoker(method, request, options.mergedWith(_options));
//
//   @override
//   ResponseStream<R> interceptStreaming<Q, R>(
//     ClientMethod<Q, R> method,
//     Stream<Q> requests,
//     CallOptions options,
//     ClientStreamingInvoker<Q, R> invoker,
//   ) => invoker(method, requests, options.mergedWith(_options));
// }
// ```
