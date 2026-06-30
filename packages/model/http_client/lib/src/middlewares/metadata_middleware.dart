import 'package:http_client/src/api_client.dart';
import 'package:meta/meta.dart';

/// {@template metadata_middleware}
/// Middleware for adding a fixed set of metadata headers to every API request.
///
/// Transport-neutral by design: it takes a ready [headers] map and merges it into each request —
/// it does NOT know about app models. The app composes the map (e.g. `AppMetadata.toHeaders()` plus
/// an `X-Environment`) at wiring time and passes it here. Mirrors gRPC's `GrpcMetadataMiddleware`,
/// which likewise accepts a plain `Map<String, String>` so both transports stay symmetric.
///
/// First-party only: never attach this to a client that talks to third-party hosts (e.g. S3
/// presigned uploads) — internal metadata must not leak off-origin.
/// {@endtemplate}
@immutable
class MetadataMiddleware {
  /// {@macro metadata_middleware}
  MetadataMiddleware({required Map<String, String> headers}) : _headers = Map<String, String>.unmodifiable(headers);

  final Map<String, String> _headers;

  ApiClientHandler call(ApiClientHandler innerHandler) =>
      (request, context) => innerHandler(request..headers.addAll(_headers), context);
}
