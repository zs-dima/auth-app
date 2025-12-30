// Code from the https://github.com/orgs/DoctorinaAI/repositories

import 'dart:async';
import 'dart:collection';
import 'dart:convert' show Converter, JsonEncoder, JsonDecoder, Utf8Decoder, Utf8Encoder, utf8;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:auth_app/_core/api/http/platform/http_client_vm.dart'
    // ignore: uri_does_not_exist
    if (dart.library.js_interop) 'package:auth_app/_core/api/http/platform/http_client_js.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http_package;

/// Maximum allowed response size (15 MB by default)
const int _kMaxResponseSize = 15 * 1024 * 1024;

/// A function that takes a [http_package.BaseRequest] and returns a [http_package.StreamedResponse].
/// The [context] parameter is a map that can be used to store data that should be available to all middleware.
typedef ApiClientHandler = Future<ApiClientResponse> Function(ApiClientRequest request, Map<String, Object?> context);

/// A function that takes a [ApiClientHandler] and returns a [ApiClientHandler].
typedef ApiClientMiddleware = ApiClientHandler Function(ApiClientHandler innerHandler);

/// A wrapper for [ApiClientMiddleware] that allows for optional handlers.
// ignore: avoid-implicitly-nullable-extension-types, prefer-declaring-const-constructor
extension type ApiClientMiddlewareWrapper._(ApiClientMiddleware _fn) {
  /// Creates a new [ApiClientMiddleware] from the given callbacks.
  factory ApiClientMiddlewareWrapper({
    Future<void> Function(ApiClientRequest request, Map<String, Object?> context)? onRequest,
    Future<void> Function(ApiClientResponse response, Map<String, Object?> context)? onResponse,
    Future<void> Function(Object error, StackTrace stackTrace, Map<String, Object?> context)? onError,
  }) => ApiClientMiddlewareWrapper._(
    (innerHandler) => (request, context) async {
      await onRequest?.call(request, context);
      try {
        final response = await innerHandler(request, context);
        await onResponse?.call(response, context);
        return response;
      } on Object catch (error, stackTrace) {
        await onError?.call(error, stackTrace, context);
        rethrow;
      }
    },
  );

  /// Merges the given [middlewares] into a single [ApiClientMiddleware].
  factory ApiClientMiddlewareWrapper.merge(List<ApiClientMiddleware> middlewares) =>
      ApiClientMiddlewareWrapper._(switch (middlewares.length) {
        0 => (handler) => handler, // Identity function for empty middleware list
        1 => middlewares.single, // Single middleware
        _ => (handler) => middlewares.reversed.fold(handler, (handler, middleware) => middleware(handler)),
      });

  /// Call the wrapped [ApiClientMiddleware] with the given [innerHandler].
  ApiClientHandler call(ApiClientHandler innerHandler) => _fn(innerHandler);
}

/// An HTTP request with a JSON-encoded body.
extension type const ApiClientRequest(http_package.BaseRequest _request) implements http_package.BaseRequest {
  /// Creates a clone of this request with optional parameter overrides.
  ApiClientRequest clone({
    String? method,
    Uri? url,
    Map<String, String>? headers,
    Uint8List? bodyBytes,
    int? contentLength,
    int? maxRedirects,
  }) {
    final newRequest = http_package.Request(method ?? _request.method, url ?? _request.url);

    // Copy existing headers and add/override with new ones
    newRequest.headers.addAll(_request.headers);
    if (headers != null) {
      newRequest.headers.addAll(headers);
    }

    // Copy body if present
    if (bodyBytes != null) {
      newRequest.bodyBytes = bodyBytes;
    } else if (_request is http_package.Request) {
      newRequest.bodyBytes = _request.bodyBytes;
    }

    // Set max redirects
    newRequest.maxRedirects = maxRedirects ?? _request.maxRedirects;

    return ApiClientRequest(newRequest);
  }
}

/// Wrapper for a future that resolves to an [ApiClientResponse].
extension type const FutureApiClientResponse(Future<ApiClientResponse> _future) implements Future<ApiClientResponse> {
  /// Returns the status code of the response.
  Future<int> get statusCode => _future.then((response) => response.statusCode);

  /// Returns the response headers.
  Future<Map<String, String>> get headers => _future.then((response) => response.headers);

  /// Returns the response body as a bytes array.
  Future<Uint8List> toBytes() => _future.then((response) => response.toBytes());

  /// Receives the response body as a JSON object.
  Future<Map<String, Object?>> toJson() => _future.then((response) => response.toJson());

  /// Receives the response body as a text string.
  Future<String> toText() => _future.then((response) => response.toText());
}

/// An HTTP response.
final class ApiClientResponse {
  static final Converter<List<int>, Map<String, Object?>> _jsonConverter = const Utf8Decoder()
      .fuse<Object?>(const JsonDecoder())
      .cast<List<int>, Map<String, Object?>>();

  /// Create a new HTTP response.
  const ApiClientResponse({
    required this.statusCode,
    required this.headers,
    required this.contentLength,
    required this.persistentConnection,
    required this.request,
    required this.stream,
  });

  /// Status code of the response.
  final int statusCode;

  /// The response headers as a hash map.
  final Map<String, String> headers;

  /// The content length of the response body.
  final int contentLength;

  /// Whether the connection should be persistent.
  final bool persistentConnection;

  /// The original request that generated this response.
  final ApiClientRequest request;

  /// Byte stream of the response body.
  final http_package.ByteStream stream;

  /// Returns the response body as a bytes array.
  Future<Uint8List> toBytes() => stream.toBytes();

  /// Receives the response body as a JSON object.
  Future<Map<String, Object?>> toJson() async {
    final bytes = await toBytes();
    return _jsonConverter.convert(bytes);
  }

  Future<String> toText() async => utf8.decode(await toBytes());

  /// Creates a clone of this response with optional parameter overrides.
  ApiClientResponse clone({
    // Map<String, Object?>? body,
    int? statusCode,
    Map<String, String>? headers,
    int? contentLength,
    bool? persistentConnection,
    ApiClientRequest? request,
    http_package.ByteStream? stream,
  }) => ApiClientResponse(
    statusCode: statusCode ?? this.statusCode,
    headers: headers ?? Map<String, String>.of(this.headers),
    contentLength: contentLength ?? this.contentLength,
    persistentConnection: persistentConnection ?? this.persistentConnection,
    request: request ?? this.request,
    stream: stream ?? this.stream,
  );
}

/// {@template api_client}
/// An HTTP client that sends requests to a REST API.
/// {@endtemplate}
class ApiClient /* with http_package.BaseClient implements http_package.Client */ {
  /// Returns the current window origin for the HTTP client.
  /// This is used only in web environments to determine the origin of requests.
  static final String origin = $getOrigin();

  ApiClient({
    required this.baseUrl, // Base URL for the API
    http_package.Client? client, // Base HTTP client to use for requests
    Map<String, String>? headers,
    Iterable<ApiClientMiddleware>? middlewares, // Middlewares to apply for each request
    int maxRedirects = 5, // Maximum number of redirects to follow
  }) : _maxRedirects = maxRedirects,
       _headers = headers,
       middlewares = List<ApiClientMiddleware>.unmodifiable(middlewares ?? const Iterable.empty()) {
    // Create the HTTP client.
    final internalClient = client ?? $createHttpClient();

    // Always add close callback for the client being used.
    _closeCallbacks.add(internalClient.close);

    // Create the final middlewares pipeline.
    final pipeline = ApiClientMiddlewareWrapper.merge([
      /* default middlewares before custom middlewares */
      ...this.middlewares,
      /* default middlewares after custom middlewares */
    ]);

    // Create the handler.
    _handler = _createHandler(internalClient, pipeline.call);
  }

  /// The maximum number of redirects to follow.
  final int _maxRedirects;

  /// The handler that processes requests and responses.
  /// This is created from the internal HTTP client and the middleware.
  late final ApiClientHandler _handler;

  /// A stack with callbacks to be called when the client is closed.
  /// These callbacks are called in the reverse order they were added.
  /// This allows for cleanup operations to be performed in the order they were added.
  final Queue<VoidCallback> _closeCallbacks = Queue<VoidCallback>();

  /// Headers to include in requests.
  final Map<String, String>? _headers;

  /// The base URL for the API.
  final Uri Function() baseUrl;

  /// Immutable list of middlewares to apply for each request.
  final List<ApiClientMiddleware> middlewares;

  /// Sends a [method] request to the given [path].
  FutureApiClientResponse send(
    String method,
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, Object?>? context,
  }) => _sendUnstreamed(
    method: method,
    url: _mergePath(baseUrl(), path, queryParameters),
    headers: {...?_headers, ...?headers},
    body: body,
    context: context ?? <String, Object?>{},
  );

  /// Sends a GET request to the given [path].
  FutureApiClientResponse get(
    String path, {
    Map<String, String>? headers,
    Map<String, Object?>? queryParameters, // TODO Map<String, String>?
    Map<String, Object?>? context,
  }) => _sendUnstreamed(
    method: 'GET',
    url: _mergePath(baseUrl(), path, queryParameters),
    headers: {...?_headers, ...?headers},
    body: null,
    context: context ?? <String, Object?>{},
  );

  /// Sends a POST request to the given [path].
  FutureApiClientResponse post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, Object?>? context,
  }) => _sendUnstreamed(
    method: 'POST',
    url: _mergePath(baseUrl(), path, queryParameters),
    headers: {...?_headers, ...?headers},
    body: body,
    context: context ?? <String, Object?>{},
  );

  /// Sends a POST request with multipart/form-data for file uploads.
  ///
  /// The [body] parameter can contain:
  /// - `String` values: added as form fields
  /// - `num` or `bool` values: converted to string and added as form fields
  /// - `List` or `Map` values: JSON-encoded and added as form fields
  /// - `http_package.MultipartFile` values: added as file uploads
  ///
  /// Note: `Content-Type` and `Content-Length` headers are automatically set
  /// by the multipart request and should not be provided in [headers].
  FutureApiClientResponse postMultipart(
    String path, {
    Map<String, Object?>? body,
    Map<String, Object?>? queryParameters, // TODO Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object?>? context,
  }) {
    try {
      final uri = _mergePath(baseUrl(), path, queryParameters);
      final multipartRequest = http_package.MultipartRequest('POST', uri);

      // Add headers (avoid content-type and content-length as they're set by MultipartRequest)
      if (_headers != null || headers != null) {
        final mergedHeaders = {...?_headers, ...?headers};
        for (final MapEntry(:key, :value) in mergedHeaders.entries) {
          final lowerKey = key.toLowerCase();
          if (lowerKey != 'content-type' && lowerKey != 'content-length') {
            multipartRequest.headers[key] = value;
          }
        }
      }

      // Add fields with intelligent conversion
      if (body != null) {
        for (final MapEntry(:key, :value) in body.entries) {
          if (value == null) continue;

          if (value is http_package.MultipartFile) {
            multipartRequest.files.add(value);
          } else {
            final String stringValue;
            if (value is String) {
              stringValue = value;
            } else if (value is num || value is bool) {
              stringValue = value.toString();
            } else if (value is List || value is Map) {
              stringValue = const JsonEncoder().convert(value);
            } else {
              stringValue = value.toString();
            }
            multipartRequest.fields[key] = stringValue;
          }
        }
      }

      final ctx = context ?? <String, Object?>{};
      return FutureApiClientResponse(_handler(ApiClientRequest(multipartRequest), ctx));
    } on Object catch (e) {
      return FutureApiClientResponse(
        Future<ApiClientResponse>.error(
          ApiClientException$Client(
            code: 'invalid_request',
            message: 'Failed to create multipart request: $e',
            statusCode: 0,
            error: e,
            data: null,
          ),
        ),
      );
    }
  }

  /// Sends a PUT request to the given [path].
  FutureApiClientResponse put(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, Object?>? context,
  }) => _sendUnstreamed(
    method: 'PUT',
    url: _mergePath(baseUrl(), path, queryParameters),
    headers: {...?_headers, ...?headers},
    body: body,
    context: context ?? <String, Object?>{},
  );

  /// Sends a PATCH request to the given [path].
  FutureApiClientResponse patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, Object?>? context,
  }) => _sendUnstreamed(
    method: 'PATCH',
    url: _mergePath(baseUrl(), path, queryParameters),
    headers: {...?_headers, ...?headers},
    body: body,
    context: context ?? <String, Object?>{},
  );

  /// Sends a DELETE request to the given [path].
  FutureApiClientResponse delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, Object?>? context,
  }) => _sendUnstreamed(
    method: 'DELETE',
    url: _mergePath(baseUrl(), path, queryParameters),
    headers: {...?_headers, ...?headers},
    body: body,
    context: context ?? <String, Object?>{},
  );

  /// Sends a HEAD request to the given [path].
  FutureApiClientResponse head(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Map<String, Object?>? context,
  }) => _sendUnstreamed(
    method: 'HEAD',
    url: _mergePath(baseUrl(), path, queryParameters),
    headers: {...?_headers, ...?headers},
    body: null,
    context: context ?? <String, Object?>{},
  );

  /// Clone this [ApiClient] with optional parameter overrides.
  ApiClient clone({
    Uri Function()? url,
    http_package.Client? client,
    Map<String, String>? headers,
    Iterable<ApiClientMiddleware>? middlewares,
    int? maxRedirects,
  }) => ApiClient(
    baseUrl: url ?? baseUrl,
    client: client,
    headers: headers ?? _headers,
    middlewares: middlewares ?? this.middlewares,
    maxRedirects: maxRedirects ?? _maxRedirects,
  );

  /// Closes the client and cleans up any resources associated with it.
  @mustCallSuper
  void close() {
    while (_closeCallbacks.isNotEmpty) {
      final last = _closeCallbacks.removeLast();
      try {
        last();
      } on Object {
        /* ignore */
      }
    }
  }

  /// Merges the given [path] with the base URL.
  static Uri _mergePath(
    Uri base,
    String path, [
    Map<String, Object?>? queryParameters, // TODO Map<String, String>?
  ]) {
    if (path.startsWith('http://') || path.startsWith('https://')) return Uri.parse(path);
    var cleanPath = path;
    while (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);
    final uri = base.replace(path: '${base.path}/$cleanPath');

    if (queryParameters == null || queryParameters.isEmpty) return uri;

    // Convert all values to strings, filtering nulls
    final stringParams = <String, String>{};
    for (final entry in queryParameters.entries) {
      final value = entry.value;
      if (value != null) stringParams[entry.key] = value.toString();
    }

    return uri.replace(queryParameters: {...uri.queryParameters, ...stringParams});
  }

  /// Sends a non-streaming [http_package.Request] and returns a [http_package.Response].
  /// [context] should be a mutable map that can be used to store data that should be available to all middleware.
  FutureApiClientResponse _sendUnstreamed({
    required String method,
    required Uri url,
    required Map<String, String>? headers,
    required Object? body,
    required Map<String, Object?> context,
  }) {
    const utf8Encoder = Utf8Encoder();
    final request = http_package.Request(method, url)
      ..maxRedirects = _maxRedirects
      ..followRedirects = _maxRedirects > 0;

    if (headers != null) request.headers.addAll(headers);
    switch (body) {
      case null:
        break; // No body, do nothing

      case final List<int> list:
        // Directly set body bytes
        final bytes = list is Uint8List ? list : Uint8List.fromList(list);
        request.headers
          ..putIfAbsent('Content-Type', () => 'application/octet-stream')
          ..putIfAbsent('Content-Length', () => bytes.length.toString());
        request.bodyBytes = bytes;

      case final String str:
        // Set body as string
        final bytes = utf8Encoder.convert(str);
        request.headers
          ..putIfAbsent('Content-Type', () => 'text/plain; charset=UTF-8')
          ..putIfAbsent('Content-Length', () => bytes.length.toString());
        request.bodyBytes = bytes;

      case final Map<String, Object?> map:
        // Set body as JSON string
        const jsonEncoder = kDebugMode ? JsonEncoder.withIndent('  ') : JsonEncoder();
        final bytes = jsonEncoder.fuse(utf8Encoder).convert(map);
        request.headers
          ..putIfAbsent('Content-Type', () => 'application/json; charset=UTF-8')
          ..putIfAbsent('Content-Length', () => bytes.length.toString());
        request.bodyBytes = bytes;

      default:
        assert(
          false,
          'Unsupported body type: ${body.runtimeType}. Supported types are: null, List<int>, String, Map<String, Object?>.',
        );
    }
    return FutureApiClientResponse(_handler(ApiClientRequest(request), context));
  }
}

/// Creates a new [ApiClientHandler] from the given [internalClient] and [middleware].
ApiClientHandler _createHandler(http_package.Client internalClient, ApiClientMiddleware middleware) {
  // Check if the completer is completed and throw an error if it is.
  void throwError(Completer<ApiClientResponse> completer, Object error, StackTrace stackTrace) {
    if (completer.isCompleted)
      return;
    else if (error is ApiClientException)
      completer.completeError(error, stackTrace);
    else
      completer.completeError(
        ApiClientException$Client(
          code: 'unknown_error',
          message: 'Unknown error.',
          statusCode: 0,
          error: error,
          data: null,
        ),
        stackTrace,
      );
  }

  // HTTP handler.
  Future<ApiClientResponse> httpHandler(ApiClientRequest request, Map<String, Object?> context) {
    final completer = Completer<ApiClientResponse>();
    // Handle top level errors.
    runZonedGuarded<void>(
      () async {
        assert(request.url.scheme.startsWith('http'), 'Invalid URL: ${request.url}');

        // Send a base request.
        final http_package.StreamedResponse streamedResponse;
        try {
          streamedResponse = await internalClient.send(request._request);
        } on Object catch (error, stackTrace) {
          throwError(
            completer,
            ApiClientException$Network(
              code: 'network_error',
              message: 'Failed to send request due to a network error.',
              statusCode: 0,
              error: error,
              data: null,
            ),
            stackTrace,
          );
          return;
        }

        // Check response.
        int statusCode;
        try {
          statusCode = streamedResponse.statusCode;
          switch (statusCode) {
            case 509:
              throw ApiClientException$Network(
                code: 'bandwidth_limit_exceeded',
                message: 'Bandwidth limit exceeded (HTTP 509).',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              );

            case 503:
              throw ApiClientException$Network(
                code: 'service_unavailable',
                message: 'Service unavailable (HTTP 503). The server is currently unable to handle the request.',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              );

            case 501:
              throw ApiClientException$Network(
                code: 'not_implemented',
                message: 'Not implemented (HTTP 501).',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              );

            case 500:
              throw ApiClientException$Network(
                code: 'internal_server_error',
                message: 'Internal server error (HTTP 500).',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              );

            case > 499:
              throw ApiClientException$Network(
                code: 'server_error',
                message: 'Internal server error (HTTP $statusCode).',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              );

            case 429:
              throw ApiClientException$Network(
                code: 'rate_limit',
                message: 'Rate limit exceeded (HTTP 429). Too many requests.',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              );

            case 422:
              throw ApiClientException$Network(
                code: 'validation_error',
                message: 'Validation error (HTTP 422). Request data is invalid.',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              );

            case 413:
              throw ApiClientException$Network(
                code: 'payload_too_large',
                message: 'Payload too large (HTTP 413). The request payload is too large.',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              );

            case 412:
              throw ApiClientException$Network(
                code: 'precondition_failed',
                message: 'Precondition failed (HTTP 412). The request failed due to a precondition error.',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              );

            case 409:
              throw ApiClientException$Network(
                code: 'conflict',
                message:
                    'Conflict (HTTP 409). The request could not be completed due to a conflict with the current state of the resource.',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              );

            case 404:
              throw ApiClientException$Network(
                code: 'not_found',
                message: 'Resource not found (HTTP 404).',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              );

            case 403:
              throw ApiClientException$Authentication(
                code: 'forbidden',
                message: 'Forbidden access (HTTP 403). Insufficient permissions.',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              );

            case 401:
              throw ApiClientException$Authentication(
                code: 'unauthorized',
                message: 'Unauthorized access (HTTP 401). Authentication required.',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              );

            case 400:
              throw ApiClientException$Network(
                code: 'bad_request',
                message: 'Bad request (HTTP 400). The request was malformed or invalid.',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              );

            case > 399:
              throw ApiClientException$Network(
                code: 'client_error',
                message: 'Client error (HTTP $statusCode).',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              );
            /* case > 299:
              throw ApiClientException$Network(
                code: 'redirection',
                message: 'Request was redirected (HTTP $statusCode).',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'url': request.url.toString()},
              ); */

            default:
              break;
          }
        } on Object catch (error, stackTrace) {
          throwError(completer, error, stackTrace);
          return;
        }

        // Read the response stream.
        int contentLength;
        http_package.ByteStream byteStream;
        try {
          contentLength = streamedResponse.contentLength ?? 0;

          // Check content length limit
          if (contentLength > _kMaxResponseSize) {
            throwError(
              completer,
              ApiClientException$Client(
                code: 'response_too_large',
                message:
                    'Response size ($contentLength bytes) exceeds maximum allowed size ($_kMaxResponseSize bytes).',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'contentLength': contentLength, 'maxSize': _kMaxResponseSize},
              ),
              StackTrace.current,
            );
            return;
          }

          byteStream = contentLength > 0 || streamedResponse.headers['content-type'] != null
              ? streamedResponse.stream
              : const http_package.ByteStream(Stream.empty());
        } on Object catch (error, stackTrace) {
          throwError(
            completer,
            ApiClientException$Client(
              code: 'body_stream_error',
              message: 'Failed to read response stream.',
              statusCode: streamedResponse.statusCode,
              error: error,
              data: null,
            ),
            stackTrace,
          );
          return;
        }

        // Complete the completer.
        if (!completer.isCompleted) {
          // Decode the response.
          final response = ApiClientResponse(
            stream: byteStream,
            statusCode: streamedResponse.statusCode,
            headers: streamedResponse.headers,
            contentLength: contentLength,
            persistentConnection: streamedResponse.persistentConnection,
            request: request,
          );

          completer.complete(response);
        }
      },
      (error, stackTrace) {
        throwError(completer, error, stackTrace);
      },
    );

    return completer.future;
  }

  return middleware(httpHandler);
}

// --- Errors --- //

@immutable
abstract class ApiClientException implements Exception {
  const ApiClientException();

  /// HTTP status code.
  /// If the request was not sent, this will be 0.
  abstract final int statusCode;

  /// Error code.
  abstract final String code;

  /// Error message.
  abstract final String message;

  /// The source error object.
  abstract final Object? error;

  /// Additional data.
  abstract final Object? data;

  @override
  String toString() => message;
}

/// Client exception.
final class ApiClientException$Client extends ApiClientException {
  const ApiClientException$Client({
    required this.code,
    required this.message,
    required this.statusCode,
    this.error,
    this.data,
  });

  @override
  final String code;

  @override
  final String message;

  @override
  final int statusCode;

  @override
  final Object? error;

  @override
  final Object? data;
}

/// Network exception.
final class ApiClientException$Network extends ApiClientException {
  const ApiClientException$Network({
    required this.code,
    required this.message,
    required this.statusCode,
    this.error,
    this.data,
  });

  @override
  final String code;

  @override
  final String message;

  @override
  final int statusCode;

  @override
  final Object? error;

  @override
  final Object? data;
}

/// Authentication exception.
final class ApiClientException$Authentication extends ApiClientException {
  const ApiClientException$Authentication({
    required this.code,
    required this.message,
    required this.statusCode,
    this.error,
    this.data,
  });

  @override
  final String code;

  @override
  final String message;

  @override
  final int statusCode;

  @override
  final Object? error;

  @override
  final Object? data;
}

// --- Multipart form data --- //

/// {@template multipart_form_data_builder}
/// Builder for creating multipart form data requests.
/// This builder allows you to add fields and files to the form data.
/// {@endtemplate}
class MultipartFormDataBuilder {
  /// Randomly-generated characters used in multipart boundaries.
  static final math.Random _random = math.Random();

  static final _newlineRegExp = RegExp(r'\r\n|\r|\n');

  /// A regular expression that matches strings that are composed entirely of
  /// ASCII-compatible characters.
  static final _asciiOnly = RegExp(r'^[\x00-\x7F]+$');

  /// {@macro multipart_form_data_builder}
  MultipartFormDataBuilder()
    : fields = <String, String>{},
      files = <({String field, String? fileName, String contentType, List<int> bytes})>[];

  /// The form fields to send for this request.
  final Map<String, String> fields;

  /// The files to send for this request.
  /// `field` is a unique identifier of field in the form data
  /// `fileName` is the name of the file, e.g. `image.png`, `document.pdf`, etc.
  /// `contentType` is the MIME type of the file, e.g. `image/png`, `application/pdf`, `application/octet-stream`, etc.
  /// `bytes` is the file content as a byte array, e.g. `Uint8List` or `List<int>`.
  final List<({String field, String? fileName, String contentType, List<int> bytes})> files;

  /// Returns a map of fields and files to be used in a multipart form data request.
  void addField(String name, String value) {
    assert(!fields.containsKey(name), 'Field with name "$name" already exists.');
    fields[name] = value;
  }

  /// Adds a file to the form data.
  void addFile(String field, List<int> bytes, {String? fileName, String contentType = 'application/octet-stream'}) {
    files.add((field: field, fileName: fileName, contentType: contentType, bytes: bytes));
  }

  /// Finalizes the form data and returns the content type and body.
  /// The content type is `multipart/form-data` with a randomly-generated boundary.
  ({String contentType, Uint8List body}) finalize() {
    if (fields.isEmpty && files.isEmpty) {
      throw StateError('Cannot finalize empty form data');
    }

    final boundary = _boundaryString();
    final contentType = 'multipart/form-data; boundary=$boundary';
    const emptyLine = <int>[13, 10]; // \r\n
    const utf8encoder = Utf8Encoder();
    final separator = utf8encoder.convert('--$boundary\r\n');
    final close = utf8encoder.convert('--$boundary--\r\n');

    final builder = BytesBuilder(copy: false);
    for (final MapEntry(key: field, :value) in fields.entries)
      builder
        ..add(separator)
        ..add(utf8encoder.convert(_headerForField(name: field, value: value)))
        ..add(utf8encoder.convert(value))
        ..add(emptyLine);

    for (final (:String field, :String? fileName, :String contentType, :List<int> bytes) in files)
      builder
        ..add(separator)
        ..add(utf8encoder.convert(_headerForFile(contentType: contentType, field: field, fileName: fileName)))
        ..add(bytes)
        ..add(emptyLine);

    builder.add(close);
    fields.clear();
    files.clear();

    return (contentType: contentType, body: builder.takeBytes());
  }

  /// Returns whether [string] is composed entirely of ASCII-compatible
  /// characters.
  static bool isPlainAscii(String string) => _asciiOnly.hasMatch(string);

  /// Returns the header string for a field.
  ///
  /// The return value is guaranteed to contain only ASCII characters.
  static String _headerForField({required String name, required String value}) {
    var header = 'content-disposition: form-data; name="${_browserEncode(name)}"';
    if (!isPlainAscii(value)) {
      header =
          '$header\r\n'
          'content-type: text/plain; charset=utf-8\r\n'
          'content-transfer-encoding: binary';
    }
    return '$header\r\n\r\n';
  }

  /// Returns the header string for a file.
  ///
  /// The return value is guaranteed to contain only ASCII characters.
  static String _headerForFile({required String contentType, required String field, required String? fileName}) {
    var header =
        'content-type: $contentType\r\n'
        'content-disposition: form-data; name="${_browserEncode(field)}"';

    if (fileName != null) header = '$header; filename="${_browserEncode(fileName)}"';

    return '$header\r\n\r\n';
  }

  /// Encode [value] in the same way browsers do.
  static String _browserEncode(String value) =>
      // http://tools.ietf.org/html/rfc2388 mandates some complex encodings for
      // field names and file names, but in practice user agents seem not to
      // follow this at all. Instead, they URL-encode `\r`, `\n`, and `\r\n` as
      // `\r\n`; URL-encode `"`; and do nothing else (even for `%` or non-ASCII
      // characters). We follow their behavior.
      value.replaceAll(_newlineRegExp, '%0D%0A').replaceAll('"', '%22');

  /// Returns a randomly-generated multipart boundary string
  static String _boundaryString() {
    // The total length of the multipart boundaries used when building the
    // request body.
    // According to http://tools.ietf.org/html/rfc1341.html, this can't be longer
    // than 70.
    const boundaryLength = 70;
    const prefix = 'http-boundary-';
    final list = List<int>.generate(
      boundaryLength - prefix.length,
      (index) => _boundaryCharacters[_random.nextInt(_boundaryCharacters.length)],
      growable: false,
    );
    return '$prefix${String.fromCharCodes(list)}';
  }
}

/// All character codes that are valid in multipart boundaries.
///
/// This is the intersection of the characters allowed in the `bcharsnospace`
/// production defined in [RFC 2046][] and those allowed in the `token`
/// production defined in [RFC 1521][].
///
/// [RFC 2046]: http://tools.ietf.org/html/rfc2046#section-5.1.1.
/// [RFC 1521]: https://tools.ietf.org/html/rfc1521#section-4
const List<int> _boundaryCharacters = <int>[
  43,
  95,
  45,
  46,
  48,
  49,
  50,
  51,
  52,
  53,
  54,
  55,
  56,
  57,
  65,
  66,
  67,
  68,
  69,
  70,
  71,
  72,
  73,
  74,
  75,
  76,
  77,
  78,
  79,
  80,
  81,
  82,
  83,
  84,
  85,
  86,
  87,
  88,
  89,
  90,
  97,
  98,
  99,
  100,
  101,
  102,
  103,
  104,
  105,
  106,
  107,
  108,
  109,
  110,
  111,
  112,
  113,
  114,
  115,
  116,
  117,
  118,
  119,
  120,
  121,
  122,
];
