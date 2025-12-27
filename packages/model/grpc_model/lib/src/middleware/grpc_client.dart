import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc/service_api.dart' as service_api;
import 'package:grpc_model/src/middleware/grpc_middleware.dart';

/// A gRPC client that supports middleware for intercepting requests.
///
/// Similar to HTTP client middleware pattern, this allows composable
/// request/response processing through a chain of middlewares.
///
/// Middlewares are applied in order, with the first middleware being
/// the outermost (first to process request, last to process response).
///
/// Example:
/// ```dart
/// final client = GrpcClient(
///   channel: channel,
///   middlewares: [
///     GrpcMetadataMiddleware(metadata: {'x-app': 'myapp'}),
///     GrpcLoggerMiddleware(),
///     GrpcRetryMiddleware(retries: 3),
///     GrpcTimeoutMiddleware(duration: Duration(seconds: 30)),
///     GrpcAuthenticationMiddleware(getToken: () => getToken()),
///   ],
/// );
///
/// final response = await client.unary(method, request);
/// ```
class GrpcClient {
  /// Creates a new gRPC client with the specified channel and middlewares.
  GrpcClient({
    required service_api.ClientChannel channel,
    List<GrpcMiddlewareBase> middlewares = const [],
    CallOptions? defaultOptions,
  }) : _channel = channel,
       _defaultOptions = defaultOptions ?? CallOptions(),
       _middlewares = middlewares;

  final CallOptions _defaultOptions;
  final List<GrpcMiddlewareBase> _middlewares;
  final service_api.ClientChannel _channel;

  /// The underlying channel for direct access if needed.
  service_api.ClientChannel get channel => _channel;

  /// Makes a unary gRPC call through the middleware chain.
  Future<R> unary<Q, R>(ClientMethod<Q, R> method, Q request, {CallOptions? options}) async {
    final ctx = <String, Object?>{'call_type': 'unary'};
    final grpcRequest = GrpcRequest<Q, R>(
      method: method,
      requests: Stream.value(request),
      options: _defaultOptions.mergedWith(options ?? CallOptions()),
    );

    final handler = _buildHandlerChain<Q, R>();
    final response = await handler(grpcRequest, ctx);
    return response.data;
  }

  /// Makes a unary gRPC call and returns a [ResponseFuture].
  ///
  /// This method applies middlewares by building [CallOptions] with metadata providers.
  ResponseFuture<R> unaryCall<Q, R>(ClientMethod<Q, R> method, Q request, {CallOptions? options}) {
    final mergedOptions = _buildOptionsWithMiddlewares(options);
    return ResponseFuture(_channel.createCall(method, Stream.value(request), mergedOptions));
  }

  /// Makes a server streaming gRPC call.
  ///
  /// This method applies middlewares by building [CallOptions] with metadata providers.
  ResponseStream<R> serverStreaming<Q, R>(ClientMethod<Q, R> method, Q request, {CallOptions? options}) {
    final mergedOptions = _buildOptionsWithMiddlewares(options);
    return ResponseStream(_channel.createCall(method, Stream.value(request), mergedOptions));
  }

  /// Makes a client streaming gRPC call through the middleware chain.
  Future<R> clientStreaming<Q, R>(ClientMethod<Q, R> method, Stream<Q> requests, {CallOptions? options}) async {
    final ctx = <String, Object?>{'call_type': 'client_streaming'};
    final grpcRequest = GrpcRequest<Q, R>(
      method: method,
      requests: requests,
      options: _defaultOptions.mergedWith(options ?? CallOptions()),
    );

    final handler = _buildHandlerChain<Q, R>();
    final response = await handler(grpcRequest, ctx);
    return response.data;
  }

  /// Makes a bidirectional streaming gRPC call.
  ///
  /// This method applies middlewares by building [CallOptions] with metadata providers.
  ResponseStream<R> bidiStreaming<Q, R>(ClientMethod<Q, R> method, Stream<Q> requests, {CallOptions? options}) {
    final mergedOptions = _buildOptionsWithMiddlewares(options);
    return ResponseStream(_channel.createCall(method, requests, mergedOptions));
  }

  /// Shuts down the underlying channel.
  Future<void> shutdown() => _channel.shutdown();

  /// Terminates the underlying channel immediately.
  Future<void> terminate() => _channel.terminate();

  /// Builds [CallOptions] with metadata providers from middlewares.
  ///
  /// This allows [ResponseFuture] and [ResponseStream] methods to benefit from
  /// metadata-adding middlewares (like auth and metadata middlewares).
  CallOptions _buildOptionsWithMiddlewares(CallOptions? options) {
    final providers = <MetadataProvider>[];

    // Extract metadata providers from middlewares
    for (final middleware in _middlewares) {
      final provider = middleware.metadataProvider;
      if (provider != null) providers.add(provider);
    }

    return _defaultOptions.mergedWith(
      (options ?? CallOptions()).mergedWith(CallOptions(providers: providers)),
    );
  }

  GrpcHandler<Q, R> _buildHandlerChain<Q, R>() {
    // ignore: omit_local_variable_types
    GrpcHandler<Q, R> handler = _executeCall;

    // Apply middlewares in reverse order so first middleware is outermost
    for (final middleware in _middlewares.reversed) {
      handler = middleware<Q, R>(handler);
    }

    return handler;
  }

  Future<GrpcResponse<R>> _executeCall<Q, R>(GrpcRequest<Q, R> request, GrpcContext context) async {
    try {
      final call = _channel.createCall(request.method, request.requests, request.options);
      final response = await ResponseFuture(call);
      final headers = await call.headers;
      final trailers = await call.trailers;

      return GrpcResponse<R>(data: response, headers: headers, trailers: trailers);
    } on GrpcError catch (e, s) {
      Error.throwWithStackTrace(GrpcClientException.fromGrpcError(e), s);
    }
  }
}
