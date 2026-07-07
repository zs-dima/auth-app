// Two middleware contracts coexist here, intentionally (A13):
//   1. High-level [ConnectMiddleware] (handle/handleStreaming with a (path, metadata) handler) —
//      for middleware that wrap the invoker (auth, sentry, logger, metadata). Prefer this for new
//      middleware.
//   2. Raw connect-dart [Interceptor] (a callable class over the typed request/response flow) —
//      for middleware that need typed errors and request identity (retry).

// Core middleware infrastructure (high-level contract #1)
export 'connect_middleware.dart';
// Compression moved to a Transport-level option — see the file's doc note (standby).
export 'middlewares/compression_middleware.dart';
export 'middlewares/metadata_middleware.dart';
// Retry uses the raw Interceptor contract (#2); see the file's doc comment.
export 'middlewares/retry_middleware.dart';
