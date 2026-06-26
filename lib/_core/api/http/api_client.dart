// Code from the https://github.com/orgs/DoctorinaAI/repositories

import 'dart:async';
import 'dart:collection';
import 'dart:convert' show Converter, JsonEncoder, JsonDecoder, Utf8Decoder, Utf8Encoder, utf8;

import 'package:auth_app/_core/api/http/platform/http_client_vm.dart'
    // ignore: uri_does_not_exist
    if (dart.library.js_interop) 'package:auth_app/_core/api/http/platform/http_client_js.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http_package;

/// Maximum allowed response size (15 MB by default)
const int _kMaxResponseSize = 15 * 1024 * 1024;

/// Response bodies larger than this are JSON-decoded on a background isolate (via `compute`)
/// instead of the UI isolate, so big payloads don't block the current frame.
const int kJsonIsolateThreshold = 32 * 1024;

/// Top-level JSON decoder for [compute] — must be a top-level/static function with a
/// sendable argument and result.
Object? _decodeJsonBytes(List<int> bytes) => const Utf8Decoder().fuse<Object?>(const JsonDecoder()).convert(bytes);

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

/// Context key under which [ApiClient] exposes the effective [CancelToken] for a
/// request, so middlewares (e.g. timeout) can abort the underlying socket.
const kCancelTokenContextKey = 'cancelToken';

/// Context flag that opts a request out of automatic retries (RetryMiddleware) and the
/// `401` refresh-retry (AuthenticationMiddleware). Used for non-resendable bodies (multipart).
const kNoRetryContextKey = 'no-retry';

/// Context flag that opts a non-idempotent request (POST/PATCH) back into automatic
/// retries — set it only when the endpoint is safe to repeat (e.g. has an idempotency key).
const kRetryNonIdempotentContextKey = 'retry-non-idempotent';

/// Context flag (`true`) marking a long-lived/server-sent-events request that must **not** be
/// retried by RetryMiddleware. Set it alongside [kStreamResponseContextKey] for SSE streams.
const kSseContextKey = 'sse';

/// Per-request override (bytes) for the maximum buffered response size. `0` or negative
/// disables the limit. Falls back to [ApiClient.maxResponseSize] when absent.
const kMaxResponseSizeContextKey = 'max-response-size';

/// Context flag (`true`) that streams the response: the size cap is bypassed and the raw
/// [ApiClientResponse.stream] is returned without buffering, for large downloads.
const kStreamResponseContextKey = 'stream-response';

/// Context value: `void Function(int received, int total)` invoked as the response body is
/// read. `total` is the `Content-Length`, or `-1` when the server did not declare one.
const kOnReceiveProgressContextKey = 'on-receive-progress';

/// Per-request override: `bool Function(int statusCode)` deciding whether a response is a
/// success. Falls back to [ApiClient.validateStatus], then to `statusCode < 400`.
const kValidateStatusContextKey = 'validate-status';

/// A token used to cancel one or more in-flight requests.
///
/// Pass the same token to several requests to cancel them together (e.g. when
/// leaving a screen). Backed by a [Completer] that drives `package:http`'s
/// [http_package.Abortable.abortTrigger]; completing it aborts the request and
/// surfaces an [ApiClientException$Cancelled] to the caller.
class CancelToken {
  final Completer<void> _completer = Completer<void>();

  /// Child tokens that cancel together with this one (e.g. per-request tokens
  /// linked to a session token). Created lazily; only holds *active* children —
  /// each detaches on completion (see [link]) so it never grows with total requests.
  Set<CancelToken>? _children;

  /// Whether [cancel] has already been called.
  bool get isCancelled => _completer.isCompleted;

  /// Future that completes when the token is cancelled. Wired into
  /// [http_package.AbortableRequest.abortTrigger].
  Future<void> get whenCancel => _completer.future;

  /// Number of currently-linked child tokens (for tests/diagnostics).
  @visibleForTesting
  int get debugLinkedCount => _children?.length ?? 0;

  Object? _reason;

  /// The reason passed to [cancel], if any.
  Object? get reason => _reason;

  /// Cancels this token (and any linked children, transitively). Idempotent.
  void cancel([Object? reason]) {
    if (_completer.isCompleted) return;
    // Iterative traversal (no recursion) over this token and its linked children.
    final pending = <CancelToken>[this];
    while (pending.isNotEmpty) {
      final token = pending.removeLast();
      if (token._completer.isCompleted) continue;
      token._reason = reason;
      token._completer.complete();
      final children = token._children;
      token._children = null;
      if (children != null) pending.addAll(children);
    }
  }

  VoidCallback link(CancelToken child) {
    if (isCancelled) {
      child.cancel(_reason);
      return () {};
    }
    (_children ??= <CancelToken>{}).add(child);
    return () => _children?.remove(child);
  }
}

/// An HTTP request with a JSON-encoded body.
extension type const ApiClientRequest(http_package.BaseRequest _request) implements http_package.BaseRequest {
  /// `true` when this request's body is fully materialized in memory and can therefore be
  /// safely re-sent via [clone]. Returns `false` for `MultipartRequest` / `StreamedRequest`,
  /// whose bodies are consumed on the first send and cannot be replayed — retry/refresh
  /// middlewares must skip the retry path for these to avoid silently stripping the body.
  bool get canBeRetried => _request is http_package.Request;

  /// Creates a clone of this request with optional parameter overrides.
  ApiClientRequest clone({
    String? method,
    Uri? url,
    Map<String, String>? headers,
    Uint8List? bodyBytes,
    int? contentLength,
    int? maxRedirects,
  }) {
    final source = _request;
    // Preserve cancellation: rebuild an AbortableRequest carrying the same
    // abortTrigger so retried attempts (see RetryMiddleware) stay abortable.
    final abortTrigger = source is http_package.Abortable ? source.abortTrigger : null;
    final newRequest = abortTrigger == null
        ? http_package.Request(method ?? source.method, url ?? source.url)
        : http_package.AbortableRequest(method ?? source.method, url ?? source.url, abortTrigger: abortTrigger);

    newRequest.headers.addAll(source.headers);
    if (headers != null) {
      newRequest.headers.addAll(headers); // overrides
    }

    if (bodyBytes != null) {
      newRequest.bodyBytes = bodyBytes;
    } else if (source is http_package.Request) {
      newRequest.bodyBytes = source.bodyBytes; // a StreamedRequest/Multipart body can't be replayed
    }

    newRequest
      ..maxRedirects = maxRedirects ?? source.maxRedirects
      ..followRedirects = source.followRedirects;

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

  /// Receives the response body as a JSON list.
  Future<List<Object?>> toJsonList() => _future.then((response) => response.toJsonList());

  /// Receives the response body as a text string.
  Future<String> toText() => _future.then((response) => response.toText());
}

/// An HTTP response.
final class ApiClientResponse {
  static final Converter<List<int>, Object?> _jsonDecoder = const Utf8Decoder().fuse<Object?>(const JsonDecoder());

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
  ///
  /// Single-subscription: the body can be read **once**. Call exactly one of
  /// [toBytes], [toJson], or [toText] per response — a second read throws
  /// "Stream has already been listened to".
  final http_package.ByteStream stream;

  /// Returns the response body as a bytes array. Consumes [stream] (read once).
  Future<Uint8List> toBytes() => stream.toBytes();

  /// Receives the response body as a JSON object. Consumes [stream] (read once).
  /// Throws [FormatException] if the body is not a JSON object.
  Future<Map<String, Object?>> toJson() async {
    final decoded = await _decode(await toBytes());
    if (decoded is Map<String, Object?>) return decoded;
    if (decoded is Map) return decoded.cast<String, Object?>();
    throw FormatException('Expected JSON object but got ${decoded.runtimeType}');
  }

  /// Receives the response body as a JSON list. Consumes [stream] (read once).
  /// Throws [FormatException] if the body is not a JSON array.
  Future<List<Object?>> toJsonList() async {
    final decoded = await _decode(await toBytes());
    if (decoded is List<Object?>) return decoded;
    if (decoded is List) return decoded.cast<Object?>();
    throw FormatException('Expected JSON array but got ${decoded.runtimeType}');
  }

  /// Receives the response body as text. Consumes [stream] (read once).
  Future<String> toText() async => utf8.decode(await toBytes());

  /// Creates a clone of this response with optional parameter overrides.
  ApiClientResponse clone({
    int? statusCode,
    Map<String, String>? headers,
    int? contentLength,
    bool? persistentConnection,
    ApiClientRequest? request,
    http_package.ByteStream? stream,
  }) => .new(
    statusCode: statusCode ?? this.statusCode,
    headers: headers ?? Map<String, String>.of(this.headers),
    contentLength: contentLength ?? this.contentLength,
    persistentConnection: persistentConnection ?? this.persistentConnection,
    request: request ?? this.request,
    stream: stream ?? this.stream,
  );

  /// Decodes [bytes] as JSON, offloading payloads larger than [kJsonIsolateThreshold] to a
  /// background isolate (`compute`) so big responses don't block the UI frame; small bodies are
  /// decoded inline to avoid isolate-spawn overhead.
  Future<Object?> _decode(List<int> bytes) async => bytes.length > kJsonIsolateThreshold
      ? await compute(_decodeJsonBytes, bytes, debugLabel: 'ApiClient.decodeJson')
      : _jsonDecoder.convert(bytes);
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
    CancelToken? Function()? sessionToken, // Session-scoped cancellation (cancelled on logout)
    this.maxResponseSize = _kMaxResponseSize, // Max buffered response size (bytes); 0/neg = unlimited
    this.validateStatus, // Decides success per status code; defaults to `code < 400`
  }) : _maxRedirects = maxRedirects,
       _headers = headers,
       _sessionToken = sessionToken,
       middlewares = List<ApiClientMiddleware>.unmodifiable(middlewares ?? const Iterable.empty()) {
    final http_package.Client internalClient;
    if (client == null) {
      // Best-effort QUIC hint for our own API host so Cronet attempts HTTP/3 on the first
      // request. `baseUrl` is a lazy resolver and may be unready/throw — then the hint is omitted.
      Uri? base;
      try {
        base = baseUrl();
      } on Object {
        base = null;
      }
      internalClient = $createHttpClient(quicHints: quicHintsForBaseUrl(base));
    } else {
      internalClient = client;
    }
    // Closed in reverse order on close(); the internal client is closed last.
    _closeCallbacks.add(internalClient.close);
    final pipeline = ApiClientMiddlewareWrapper.merge([...this.middlewares]);
    _handler = _createHandler(internalClient, pipeline.call, maxResponseSize, validateStatus);
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

  /// Returns the current session-scoped [CancelToken] (or `null`). Every request aborts
  /// when this token is cancelled, so ending the session (logout / failed refresh) tears
  /// down all in-flight requests bound to it.
  final CancelToken? Function()? _sessionToken;

  /// The base URL for the API.
  final Uri Function() baseUrl;

  /// Immutable list of middlewares to apply for each request.
  final List<ApiClientMiddleware> middlewares;

  /// Default maximum buffered response size in bytes. `0` or negative disables the limit.
  /// Overridable per request via [kMaxResponseSizeContextKey]; bypassed entirely when the
  /// request opts into streaming ([kStreamResponseContextKey]).
  final int maxResponseSize;

  /// Decides whether a response [statusCode] is a success. When it returns `false` the
  /// response is mapped to a typed [ApiClientException]. Defaults to `statusCode < 400`.
  /// Overridable per request via [kValidateStatusContextKey].
  final bool Function(int statusCode)? validateStatus;

  /// Best-effort QUIC hints for the client's own API host so Cronet attempts HTTP/3 on the
  /// **first** request (not just after an Alt-Svc upgrade) — assuming that host speaks HTTP/3,
  /// the same bet as `enableQuic: true`. Returns `null` for non-https, hostless, or IPv6-literal
  /// URLs (hints target hostnames); a wrong/stale hint is harmless (Cronet falls back). Consumed
  /// by the platform HTTP client factory (`$createHttpClient`); a no-op on iOS/web.
  @visibleForTesting
  static List<(String, int, int)>? quicHintsForBaseUrl(Uri? uri) {
    // `uri.host` strips IPv6 brackets (`::1`), which would be a malformed hint — skip IP-literal
    // hosts (only IPv6 contains ':'; hostnames and IPv4 never do).
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty || uri.host.contains(':')) return null;
    final port = uri.hasPort ? uri.port : 443;
    return <(String, int, int)>[(uri.host, port, port)];
  }

  /// Sends a [method] request to the given [path].
  ///
  /// [stream] returns the response body unbuffered (bypasses the size cap) for large
  /// downloads. [onReceiveProgress] is called as the body is read with
  /// `(received, total)` (`total` is the Content-Length, or `-1` when unknown).
  /// [maxResponseSize] overrides [ApiClient.maxResponseSize] for this request.
  FutureApiClientResponse send(
    String method,
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? context,
    CancelToken? cancelToken,
    bool stream = false,
    void Function(int received, int total)? onReceiveProgress,
    int? maxResponseSize,
  }) => _sendUnstreamed(
    method: method,
    url: _mergePath(baseUrl(), path, queryParameters),
    headers: {...?_headers, ...?headers},
    body: body,
    context: context ?? <String, Object?>{},
    cancelToken: cancelToken,
    stream: stream,
    onReceiveProgress: onReceiveProgress,
    maxResponseSize: maxResponseSize,
  );

  /// Sends a GET request to the given [path].
  ///
  /// [stream], [onReceiveProgress] and [maxResponseSize] behave as in [send].
  FutureApiClientResponse get(
    String path, {
    Map<String, String>? headers,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? context,
    CancelToken? cancelToken,
    bool stream = false,
    void Function(int received, int total)? onReceiveProgress,
    int? maxResponseSize,
  }) => _sendUnstreamed(
    method: 'GET',
    url: _mergePath(baseUrl(), path, queryParameters),
    headers: {...?_headers, ...?headers},
    body: null,
    context: context ?? <String, Object?>{},
    cancelToken: cancelToken,
    stream: stream,
    onReceiveProgress: onReceiveProgress,
    maxResponseSize: maxResponseSize,
  );

  /// Sends a POST request to the given [path].
  FutureApiClientResponse post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? context,
    CancelToken? cancelToken,
  }) => _sendUnstreamed(
    method: 'POST',
    url: _mergePath(baseUrl(), path, queryParameters),
    headers: {...?_headers, ...?headers},
    body: body,
    context: context ?? <String, Object?>{},
    cancelToken: cancelToken,
  );

  /// Sends a multipart/form-data request (any [method]) for file uploads.
  ///
  /// The [body] parameter can contain:
  /// - `String` values: added as form fields
  /// - `num` or `bool` values: converted to string and added as form fields
  /// - `List` or `Map` values: JSON-encoded and added as form fields
  /// - `http_package.MultipartFile` values: added as file uploads
  ///
  /// Note: `Content-Type` and `Content-Length` headers are automatically set
  /// by the multipart request and should not be provided in [headers].
  FutureApiClientResponse sendMultipart(
    String method,
    String path, {
    Map<String, Object?>? body,
    Map<String, Object?>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object?>? context,
    CancelToken? cancelToken,
  }) {
    try {
      final uri = _mergePath(baseUrl(), path, queryParameters);
      final ctx = context ?? <String, Object?>{};
      final effectiveToken = cancelToken ?? CancelToken();
      ctx[kCancelTokenContextKey] = effectiveToken;
      // A finalized MultipartRequest can't be re-sent and clone() can't rebuild it,
      // so opt this request out of automatic retry/refresh-retry to avoid an empty body.
      ctx[kNoRetryContextKey] = true;
      final multipartRequest = http_package.AbortableMultipartRequest(
        method.toUpperCase(),
        uri,
        abortTrigger: effectiveToken.whenCancel,
      );

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

      // Link to the session only now that the request is fully built, so a field-encoding failure
      // above cannot leave a dead token retained in the session token's children.
      final detachSession = _linkSession(effectiveToken);
      final future = _handler(ApiClientRequest(multipartRequest), ctx);
      future.whenComplete(detachSession).ignore();
      return FutureApiClientResponse(future);
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

  /// Sends a `POST` multipart/form-data request. Backward-compatible wrapper around [sendMultipart].
  FutureApiClientResponse postMultipart(
    String path, {
    Map<String, Object?>? body,
    Map<String, Object?>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object?>? context,
    CancelToken? cancelToken,
  }) => sendMultipart(
    'POST',
    path,
    body: body,
    queryParameters: queryParameters,
    headers: headers,
    context: context,
    cancelToken: cancelToken,
  );

  /// Sends a `POST` request with a streaming body — chunks from [bodyStream] are piped to the
  /// wire as they arrive, so large uploads never have to be fully buffered in memory.
  ///
  /// [contentLength] must match the total size of the stream (sets `Content-Length`). The body
  /// is consumed once and cannot be replayed, so the request is excluded from automatic retry.
  FutureApiClientResponse postStream(
    String path, {
    required Stream<List<int>> bodyStream,
    required int contentLength,
    Map<String, String>? headers,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? context,
    CancelToken? cancelToken,
  }) {
    final uri = _mergePath(baseUrl(), path, queryParameters);
    final ctx = context ?? <String, Object?>{};
    final effectiveToken = cancelToken ?? CancelToken();
    ctx[kCancelTokenContextKey] = effectiveToken;
    ctx[kNoRetryContextKey] = true; // streamed body is consumed on first send (also see canBeRetried)

    final streamedRequest = http_package.AbortableStreamedRequest('POST', uri, abortTrigger: effectiveToken.whenCancel)
      ..contentLength = contentLength;
    if (contentLength > 0) streamedRequest.headers['Content-Length'] = contentLength.toString();
    if (_headers != null) streamedRequest.headers.addAll(_headers);
    if (headers != null) streamedRequest.headers.addAll(headers);

    // Pipe the body stream into the request sink as chunks arrive.
    bodyStream.listen(
      streamedRequest.sink.add,
      onError: streamedRequest.sink.addError,
      onDone: streamedRequest.sink.close,
      cancelOnError: true,
    );

    // Link to the session only now that the request is fully built (uniform with the other
    // senders), so a construction failure above cannot leak a retained session-child token.
    final detachSession = _linkSession(effectiveToken);
    final future = _handler(ApiClientRequest(streamedRequest), ctx);
    future.whenComplete(detachSession).ignore();
    return FutureApiClientResponse(future);
  }

  /// Sends a PUT request to the given [path].
  FutureApiClientResponse put(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? context,
    CancelToken? cancelToken,
  }) => _sendUnstreamed(
    method: 'PUT',
    url: _mergePath(baseUrl(), path, queryParameters),
    headers: {...?_headers, ...?headers},
    body: body,
    context: context ?? <String, Object?>{},
    cancelToken: cancelToken,
  );

  /// Sends a PATCH request to the given [path].
  FutureApiClientResponse patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? context,
    CancelToken? cancelToken,
  }) => _sendUnstreamed(
    method: 'PATCH',
    url: _mergePath(baseUrl(), path, queryParameters),
    headers: {...?_headers, ...?headers},
    body: body,
    context: context ?? <String, Object?>{},
    cancelToken: cancelToken,
  );

  /// Sends a DELETE request to the given [path].
  FutureApiClientResponse delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? context,
    CancelToken? cancelToken,
  }) => _sendUnstreamed(
    method: 'DELETE',
    url: _mergePath(baseUrl(), path, queryParameters),
    headers: {...?_headers, ...?headers},
    body: body,
    context: context ?? <String, Object?>{},
    cancelToken: cancelToken,
  );

  /// Sends a HEAD request to the given [path].
  FutureApiClientResponse head(
    String path, {
    Map<String, String>? headers,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? context,
    CancelToken? cancelToken,
  }) => _sendUnstreamed(
    method: 'HEAD',
    url: _mergePath(baseUrl(), path, queryParameters),
    headers: {...?_headers, ...?headers},
    body: null,
    context: context ?? <String, Object?>{},
    cancelToken: cancelToken,
  );

  /// Clone this [ApiClient] with optional parameter overrides.
  ApiClient clone({
    Uri Function()? url,
    http_package.Client? client,
    Map<String, String>? headers,
    Iterable<ApiClientMiddleware>? middlewares,
    int? maxRedirects,
  }) => .new(
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
    Map<String, Object?>? queryParameters, // values: scalar → toString; Iterable → repeated keys; null → dropped
  ]) {
    if (path.startsWith('http://') || path.startsWith('https://')) return Uri.parse(path);
    var cleanPath = path;
    while (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);
    final uri = base.replace(path: '${base.path}/$cleanPath');

    if (queryParameters == null || queryParameters.isEmpty) return uri;

    // Build multi-valued query params: collections become repeated keys (?id=1&id=2),
    // the correct default (Dio's ListFormat.multi). Uri emits repeated keys for any
    // Iterable<String> value. Nulls (and null list elements) are dropped; an empty list
    // drops the key entirely. Existing base-URL query params are preserved.
    final merged = <String, List<String>>{};
    uri.queryParametersAll.forEach((key, value) => merged[key] = List<String>.of(value));
    for (final MapEntry(:key, :value) in queryParameters.entries) {
      if (value == null) continue; // null → no param
      if (value is Iterable) {
        final values = <String>[for (final e in value) ?e?.toString()]; // drop null elements
        if (values.isEmpty)
          merged.remove(key); // empty/all-null list → drop the key
        else
          merged[key] = values;
      } else {
        merged[key] = <String>[value.toString()];
      }
    }

    return merged.isEmpty ? uri : uri.replace(queryParameters: merged);
  }

  /// Links [requestToken] to the current session token (if any) so the request is
  /// cancelled when the session ends. Returns a detach callback to call when the request
  /// completes — keeping the session token's retained set bounded to in-flight requests.
  VoidCallback _linkSession(CancelToken requestToken) => _sessionToken?.call()?.link(requestToken) ?? () {};

  /// Sends a non-streaming [http_package.Request] and returns a [http_package.Response].
  /// [context] should be a mutable map that can be used to store data that should be available to all middleware.
  FutureApiClientResponse _sendUnstreamed({
    required String method,
    required Uri url,
    required Map<String, String> headers,
    required Object? body,
    required Map<String, Object?> context,
    CancelToken? cancelToken,
    bool stream = false,
    void Function(int received, int total)? onReceiveProgress,
    int? maxResponseSize,
  }) {
    const utf8Encoder = Utf8Encoder();
    // Always abortable: use the caller's token, or an internal one, and expose it
    // via context so middlewares (e.g. timeout) can tear down the socket. An
    // abortTrigger that never completes behaves like a normal request.
    final effectiveToken = cancelToken ?? CancelToken();
    context[kCancelTokenContextKey] = effectiveToken;
    // Seed response-handling options for httpHandler (only when set, so an explicit
    // context entry from the caller is never overwritten).
    if (stream) context[kStreamResponseContextKey] = true;
    if (onReceiveProgress != null) context[kOnReceiveProgressContextKey] = onReceiveProgress;
    if (maxResponseSize != null) context[kMaxResponseSizeContextKey] = maxResponseSize;
    final request = http_package.AbortableRequest(method, url, abortTrigger: effectiveToken.whenCancel)
      ..maxRedirects = _maxRedirects
      ..followRedirects = _maxRedirects > 0;

    request.headers.addAll(headers);
    // Encode the body by type and set Content-Type/-Length unless the caller already provided them.
    switch (body) {
      case null:
        break;

      case final List<int> list:
        final bytes = list is Uint8List ? list : Uint8List.fromList(list);
        request.headers
          ..putIfAbsent('Content-Type', () => 'application/octet-stream')
          ..putIfAbsent('Content-Length', () => bytes.length.toString());
        request.bodyBytes = bytes;

      case final String str:
        final bytes = utf8Encoder.convert(str);
        request.headers
          ..putIfAbsent('Content-Type', () => 'text/plain; charset=UTF-8')
          ..putIfAbsent('Content-Length', () => bytes.length.toString());
        request.bodyBytes = bytes;

      case final Map<String, Object?> map:
        const jsonEncoder = kDebugMode ? JsonEncoder.withIndent('  ') : JsonEncoder();
        final bytes = jsonEncoder.fuse(utf8Encoder).convert(map);
        request.headers
          ..putIfAbsent('Content-Type', () => 'application/json; charset=UTF-8')
          ..putIfAbsent('Content-Length', () => bytes.length.toString());
        request.bodyBytes = bytes;

      default:
        throw ArgumentError(
          'Unsupported body type: ${body.runtimeType}. Supported types are: null, List<int>, String, Map<String, Object?>.',
        );
    }
    // Link to the session only now that the request is fully built, so a body-encoding failure
    // above cannot leave a dead token retained in the session token's children.
    final detachSession = _linkSession(effectiveToken);
    final future = _handler(ApiClientRequest(request), context);
    future.whenComplete(detachSession).ignore();
    return FutureApiClientResponse(future);
  }
}

/// Creates a new [ApiClientHandler] from the given [internalClient] and [middleware].
///
/// [maxResponseSizeDefault] caps the buffered response size (per-request overridable via
/// [kMaxResponseSizeContextKey], bypassed by [kStreamResponseContextKey]).
/// [validateStatusDefault] decides success per status code (per-request overridable via
/// [kValidateStatusContextKey]); when `null`, `statusCode < 400` is used.
ApiClientHandler _createHandler(
  http_package.Client internalClient,
  ApiClientMiddleware middleware,
  int maxResponseSizeDefault,
  bool Function(int statusCode)? validateStatusDefault,
) {
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

  // Innermost handler: sends the request and maps the result to an ApiClientResponse/exception.
  Future<ApiClientResponse> httpHandler(ApiClientRequest request, Map<String, Object?> context) {
    final completer = Completer<ApiClientResponse>();
    // runZonedGuarded routes async errors that escape the inner try/catch through throwError.
    runZonedGuarded<void>(
      () async {
        assert(request.url.scheme.startsWith('http'), 'Invalid URL: ${request.url}');

        final http_package.StreamedResponse streamedResponse;
        try {
          streamedResponse = await internalClient.send(request._request);
        } on http_package.RequestAbortedException catch (error, stackTrace) {
          // The request was cancelled via a CancelToken — surface it distinctly
          // so callers and RetryMiddleware can tell it apart from a real failure.
          throwError(
            completer,
            ApiClientException$Cancelled(error: error, data: <String, Object?>{'url': request.url.toString()}),
            stackTrace,
          );
          return;
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

        // Validate the status code. A success passes through to the body; otherwise it is
        // mapped to a typed exception. The success predicate is resolved per request
        // ([kValidateStatusContextKey]) → client default → `statusCode < 400`.
        final statusCode = streamedResponse.statusCode;
        final isSuccess = switch (context[kValidateStatusContextKey]) {
          final bool Function(int statusCode) predicate => predicate,
          _ => validateStatusDefault ?? _defaultValidateStatus,
        };
        if (!isSuccess(statusCode)) {
          // Capture the error body (bounded) so the server's machine-readable error
          // code/message/field-errors aren't lost. Parsed as JSON when possible (any
          // content-type), else raw text; bounded in size to cap memory and telemetry exposure.
          final errorCap = switch (context[kMaxResponseSizeContextKey]) {
            final int m when m > 0 => m,
            _ => maxResponseSizeDefault > 0 ? maxResponseSizeDefault : _kMaxResponseSize,
          };
          final errorBytes = await _readErrorBody(
            streamedResponse,
            errorCap,
          ).timeout(const Duration(seconds: 10), onTimeout: () => null);
          Object? errorBody;
          if (errorBytes != null && errorBytes.isNotEmpty) {
            try {
              errorBody = _decodeJsonBytes(errorBytes);
            } on Object {
              errorBody = utf8.decode(errorBytes, allowMalformed: true);
            }
          }
          throwError(
            completer,
            // Known codes get a precise typed error; anything else falls back to a generic
            // client/server network error so a custom predicate can reject any code.
            _statusToException(statusCode, streamedResponse.headers, request.url, errorBody) ??
                ApiClientException$Network(
                  code: statusCode < 500 ? 'client_error' : 'server_error',
                  message: '${statusCode < 500 ? 'Client' : 'Server'} error (HTTP $statusCode).',
                  statusCode: statusCode,
                  error: null,
                  data: <String, Object?>{'url': request.url.toString(), 'body': ?errorBody},
                ),
            .current,
          );
          return;
        }

        // Read the response stream. A streaming request ([kStreamResponseContextKey]) bypasses
        // the size cap and the empty-body heuristic, returning the raw stream for the caller to
        // consume without buffering (large downloads).
        final streaming = context[kStreamResponseContextKey] == true;
        final maxSize = switch (context[kMaxResponseSizeContextKey]) {
          final int m => m,
          _ => maxResponseSizeDefault,
        };
        int contentLength;
        http_package.ByteStream byteStream;
        try {
          contentLength = streamedResponse.contentLength ?? 0;

          // Enforce the declared-size cap unless streaming or the cap is disabled (<= 0).
          if (!streaming && maxSize > 0 && contentLength > maxSize) {
            throwError(
              completer,
              ApiClientException$Client(
                code: 'response_too_large',
                message: 'Response size ($contentLength bytes) exceeds maximum allowed size ($maxSize bytes).',
                statusCode: statusCode,
                error: null,
                data: <String, Object?>{'contentLength': contentLength, 'maxSize': maxSize},
              ),
              .current,
            );
            return;
          }

          byteStream = !streaming && contentLength <= 0 && streamedResponse.headers['content-type'] == null
              ? const http_package.ByteStream(Stream.empty())
              : streamedResponse.stream;

          // Report download progress as the body is consumed, if a callback was provided.
          // `total` is the Content-Length, or -1 when the server did not declare one.
          if (context[kOnReceiveProgressContextKey]
              case final void Function(int received, int total) onReceiveProgress) {
            final total = contentLength > 0 ? contentLength : -1;
            var received = 0;
            byteStream = http_package.ByteStream(
              byteStream.map((chunk) {
                received += chunk.length;
                onReceiveProgress(received, total);
                return chunk;
              }),
            );
          }
        } on Object catch (error, stackTrace) {
          throwError(
            completer,
            ApiClientException$Client(
              code: 'body_stream_error',
              message: 'Failed to read response stream.',
              statusCode: statusCode,
              error: error,
              data: null,
            ),
            stackTrace,
          );
          return;
        }

        if (!completer.isCompleted) {
          completer.complete(
            ApiClientResponse(
              stream: byteStream,
              statusCode: statusCode,
              headers: streamedResponse.headers,
              contentLength: contentLength,
              persistentConnection: streamedResponse.persistentConnection,
              request: request,
            ),
          );
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

/// Default success predicate: any status below 400 (2xx/3xx) is a success.
bool _defaultValidateStatus(int statusCode) => statusCode < 400;

/// Reads an error response body up to [cap] bytes, returning `null` on overflow, abort, or a
/// stream error (so error-body capture never blows memory or masks the status error). Error
/// bodies are small; oversized ones are skipped rather than buffered.
Future<Uint8List?> _readErrorBody(http_package.StreamedResponse response, int cap) async {
  if ((response.contentLength ?? 0) > cap) return null; // declared too large → skip
  try {
    final bytes = <int>[];
    await for (final chunk in response.stream) {
      bytes.addAll(chunk);
      if (bytes.length > cap) return null; // undeclared overflow → skip
    }
    return Uint8List.fromList(bytes);
  } on Object {
    return null; // abort / stream error → fall back to the status-only error
  }
}

/// Maps a non-success [statusCode] to its typed [ApiClientException], preserving the
/// original codes/messages, the captured [errorBody] (when present), and `Retry-After` for
/// 429/503. Returns `null` for codes with no specific mapping — the caller then applies a
/// generic client/server network error.
ApiClientException? _statusToException(int statusCode, Map<String, String> headers, Uri url, Object? errorBody) {
  final retryAfter = headers['retry-after'];
  Map<String, Object?> data({bool withRetryAfter = false}) => <String, Object?>{
    'url': url.toString(),
    'body': ?errorBody,
    if (withRetryAfter) 'retry-after': ?retryAfter,
  };
  return switch (statusCode) {
    509 => ApiClientException$Network(
      code: 'bandwidth_limit_exceeded',
      message: 'Bandwidth limit exceeded (HTTP 509).',
      statusCode: statusCode,
      data: data(),
    ),
    503 => ApiClientException$Network(
      code: 'service_unavailable',
      message: 'Service unavailable (HTTP 503). The server is currently unable to handle the request.',
      statusCode: statusCode,
      data: data(withRetryAfter: true),
    ),
    501 => ApiClientException$Network(
      code: 'not_implemented',
      message: 'Not implemented (HTTP 501).',
      statusCode: statusCode,
      data: data(),
    ),
    500 => ApiClientException$Network(
      code: 'internal_server_error',
      message: 'Internal server error (HTTP 500).',
      statusCode: statusCode,
      data: data(),
    ),
    > 499 => ApiClientException$Network(
      code: 'server_error',
      message: 'Internal server error (HTTP $statusCode).',
      statusCode: statusCode,
      data: data(),
    ),
    429 => ApiClientException$Network(
      code: 'rate_limit',
      message: 'Rate limit exceeded (HTTP 429). Too many requests.',
      statusCode: statusCode,
      data: data(withRetryAfter: true),
    ),
    422 => ApiClientException$Network(
      code: 'validation_error',
      message: 'Validation error (HTTP 422). Request data is invalid.',
      statusCode: statusCode,
      data: data(),
    ),
    413 => ApiClientException$Network(
      code: 'payload_too_large',
      message: 'Payload too large (HTTP 413). The request payload is too large.',
      statusCode: statusCode,
      data: data(),
    ),
    412 => ApiClientException$Network(
      code: 'precondition_failed',
      message: 'Precondition failed (HTTP 412). The request failed due to a precondition error.',
      statusCode: statusCode,
      data: data(),
    ),
    409 => ApiClientException$Network(
      code: 'conflict',
      message:
          'Conflict (HTTP 409). The request could not be completed due to a conflict with the current state of the resource.',
      statusCode: statusCode,
      data: data(),
    ),
    404 => ApiClientException$Network(
      code: 'not_found',
      message: 'Resource not found (HTTP 404).',
      statusCode: statusCode,
      data: data(),
    ),
    403 => ApiClientException$Authentication(
      code: 'forbidden',
      message: 'Forbidden access (HTTP 403). Insufficient permissions.',
      statusCode: statusCode,
      data: data(),
    ),
    401 => ApiClientException$Authentication(
      code: 'unauthorized',
      message: 'Unauthorized access (HTTP 401). Authentication required.',
      statusCode: statusCode,
      data: data(),
    ),
    400 => ApiClientException$Network(
      code: 'bad_request',
      message: 'Bad request (HTTP 400). The request was malformed or invalid.',
      statusCode: statusCode,
      data: data(),
    ),
    > 399 => ApiClientException$Network(
      code: 'client_error',
      message: 'Client error (HTTP $statusCode).',
      statusCode: statusCode,
      data: data(),
    ),
    _ => null,
  };
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

/// Cancellation exception, thrown when a request is aborted via a [CancelToken].
final class ApiClientException$Cancelled extends ApiClientException {
  const ApiClientException$Cancelled({
    this.code = 'cancelled',
    this.message = 'Request was cancelled.',
    this.statusCode = 0,
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
