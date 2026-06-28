// Two middleware contracts coexist here, intentionally (A13):
//   1. High-level [GrpcMiddleware] (call/callStreaming with a (path, metadata) handler) — for
//      middleware that wrap the invoker (auth, sentry, logger). Prefer this for new middleware.
//   2. Raw [ClientInterceptor] (override interceptUnary/interceptStreaming) — for middleware that
//      only tweak CallOptions or need full control (metadata, compression, retry).

// Core middleware infrastructure (high-level contract #1)
export 'grpc_middleware.dart';
// Implementations below use the raw ClientInterceptor contract (#2); see each file's doc comment.
export 'middlewares/compression_middleware.dart';
export 'middlewares/metadata_middleware.dart';
export 'middlewares/retry_middleware.dart';
