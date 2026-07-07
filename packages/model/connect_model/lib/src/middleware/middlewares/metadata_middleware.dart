import 'package:connect_model/src/middleware/connect_middleware.dart';
import 'package:meta/meta.dart';

/// {@template connect_metadata_middleware}
/// Middleware for adding static metadata (headers) to Connect requests.
/// {@endtemplate}
@immutable
class ConnectMetadataMiddleware extends ConnectMiddleware {
  /// {@macro connect_metadata_middleware}
  ConnectMetadataMiddleware({required Map<String, String> metadata}) : _metadata = Map.unmodifiable(metadata);

  final Map<String, String> _metadata;

  @override
  ConnectMiddlewareHandler handle(ConnectMiddlewareHandler invoker) =>
      // Static entries win on key conflict — the same merge direction as the grpc-era
      // `options.mergedWith(CallOptions(metadata: _metadata))`.
      (path, metadata) => invoker(path, {...metadata, ..._metadata});
}
