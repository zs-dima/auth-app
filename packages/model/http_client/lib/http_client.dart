library http_client;

// CancelToken and VoidCallback are generic primitives in core_model; re-exported so the HTTP client
// API stays self-contained (and VoidCallback stays the single platform-neutral typedef — A1).
export 'package:core_model/core_model.dart' show CancelToken, VoidCallback;

// Core client: ApiClient, ApiClientHandler/Middleware/Wrapper, ApiClientRequest/Response,
// the ApiClientException hierarchy, and the request context keys.
export 'src/api_client.dart';
// JSON converter for binary (Uint8List) fields.
export 'src/byte_array_file_converter.dart';
// HTTP header-name / content-type constants.
export 'src/headers.dart';
// Generic middlewares: retry, timeout, basic authentication, metadata headers.
export 'src/middleware.dart';
