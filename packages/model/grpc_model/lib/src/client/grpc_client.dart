// ignore_for_file: omit_local_variable_types

import 'package:grpc/grpc.dart';
import 'package:grpc/service_api.dart' as service_api;

/// A gRPC client wrapper that simplifies middleware configuration.
///
/// Provides convenient methods for making gRPC calls with automatic
/// middleware/interceptor application through the native interceptor chain.
///
/// ## Recommended Usage - With Generated Stubs
///
/// The recommended approach is to use this client's interceptors with generated
/// gRPC stubs, which provides the best compatibility:
///
/// ```dart
/// final client = GrpcClient(
///   channel: ClientChannel('api.example.com', port: 443),
///   interceptors: [
///     GrpcAuthenticationMiddleware(getToken: () => getToken()),
///     GrpcLoggingMiddleware(),
///   ],
/// );
///
/// // Use with generated stub
/// final stub = MyServiceClient(client.channel, interceptors: client.interceptors);
/// final response = await stub.getData(request);
/// ```
///
/// ## Direct Usage
///
/// You can also make calls directly through the client:
///
/// ```dart
/// final response = await client.unary(MyService.getDataMethod, request);
/// ```
class GrpcClient {
  /// Creates a new gRPC client.
  ///
  /// [channel] - The underlying gRPC channel for transport.
  /// [interceptors] - List of middleware/interceptors to apply to all calls.
  /// [options] - Default call options (timeout, metadata, compression).
  GrpcClient({
    required this.channel,
    List<ClientInterceptor> interceptors = const [],
    CallOptions? options,
  }) : interceptors = List.unmodifiable(interceptors),
       _options = options ?? CallOptions();

  final CallOptions _options;

  /// The underlying gRPC channel.
  final service_api.ClientChannel channel;

  /// Interceptors applied to all calls made through this client.
  ///
  /// Pass these to generated client stubs for consistent middleware application:
  /// ```dart
  /// final stub = MyServiceClient(client.channel, interceptors: client.interceptors);
  /// ```
  final List<ClientInterceptor> interceptors;

  /// Makes a unary gRPC call.
  ///
  /// Returns a [ResponseFuture] that provides access to:
  /// - The response value (via `await`)
  /// - Response headers (via `.headers`)
  /// - Response trailers (via `.trailers`)
  /// - Cancellation (via `.cancel()`)
  ResponseFuture<R> unary<Q, R>(
    ClientMethod<Q, R> method,
    Q request, {
    CallOptions? options,
  }) {
    final mergedOptions = _options.mergedWith(options);

    // Build invoker chain (same pattern as official grpc-dart Client)
    ClientUnaryInvoker<Q, R> invoker = (m, r, o) => ResponseFuture(channel.createCall(m, Stream.value(r), o));

    for (final interceptor in interceptors.reversed) {
      final next = invoker;
      invoker = (m, r, o) => interceptor.interceptUnary(m, r, o, next);
    }

    return invoker(method, request, mergedOptions);
  }

  /// Makes a server-streaming gRPC call.
  ///
  /// The server responds with a stream of messages.
  ResponseStream<R> serverStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Q request, {
    CallOptions? options,
  }) {
    final mergedOptions = _options.mergedWith(options);

    ClientStreamingInvoker<Q, R> invoker = (m, r, o) => ResponseStream(channel.createCall(m, r, o));

    for (final interceptor in interceptors.reversed) {
      final next = invoker;
      invoker = (m, r, o) => interceptor.interceptStreaming(m, r, o, next);
    }

    return invoker(method, Stream.value(request), mergedOptions);
  }

  /// Makes a client-streaming gRPC call.
  ///
  /// The client sends a stream of messages, server responds with single message.
  ResponseFuture<R> clientStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests, {
    CallOptions? options,
  }) {
    final mergedOptions = _options.mergedWith(options);

    ClientStreamingInvoker<Q, R> invoker = (m, r, o) => ResponseStream(channel.createCall(m, r, o));

    for (final interceptor in interceptors.reversed) {
      final next = invoker;
      invoker = (m, r, o) => interceptor.interceptStreaming(m, r, o, next);
    }

    return invoker(method, requests, mergedOptions).single;
  }

  /// Makes a bidirectional streaming gRPC call.
  ///
  /// Both client and server exchange streams of messages.
  ResponseStream<R> bidiStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests, {
    CallOptions? options,
  }) {
    final mergedOptions = _options.mergedWith(options);

    ClientStreamingInvoker<Q, R> invoker = (m, r, o) => ResponseStream(channel.createCall(m, r, o));

    for (final interceptor in interceptors.reversed) {
      final next = invoker;
      invoker = (m, r, o) => interceptor.interceptStreaming(m, r, o, next);
    }

    return invoker(method, requests, mergedOptions);
  }

  /// Shuts down the channel gracefully.
  Future<void> shutdown() => channel.shutdown();

  /// Terminates the channel immediately.
  Future<void> terminate() => channel.terminate();
}
