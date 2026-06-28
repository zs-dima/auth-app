// The handler-based middleware API intentionally uses function-typedef parameters; suppress the
// matching style lints (deduplicated — A9).
// ignore_for_file: type_annotate_public_apis, avoid_dynamic, avoid-dynamic, prefer-explicit-parameter-names, use_function_type_syntax_for_parameters, prefer-async-callback, prefer-explicit-function-type

import 'dart:async';

import 'package:async/async.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_model/src/middleware/response_future_holder.dart';

typedef GrpcMiddlewareHandler = Future<void> Function(String path, Map<String, String> metadata);

/// Base class for gRPC client middleware.
///
/// Provides a simplified API similar to HTTP middleware patterns,
/// where you control the full request/response flow in a single method.
/// For advanced use cases, override [interceptUnary] or [interceptStreaming] directly.
abstract class GrpcMiddleware implements ClientInterceptor {
  /// Creates a gRPC middleware instance.
  const GrpcMiddleware();

  /// Called for each gRPC request.
  ///
  /// Override this method to:
  /// - Add headers to [metadata] (e.g., authentication tokens)
  /// - Call [invoker] to proceed with the request
  /// - Handle errors from the response
  ///
  /// The [path] is the gRPC method path (e.g., '/package.Service/Method').
  ///
  /// Example:
  /// ```dart
  /// Future<void> call(metadata, path, invoker) async {
  ///   metadata['Authorization'] = 'Bearer $token';
  ///   try {
  ///     await invoker();
  ///   } on GrpcError catch (e) {
  ///     // Handle error
  ///     rethrow;
  ///   }
  /// }
  /// ```
  GrpcMiddlewareHandler call(GrpcMiddlewareHandler invoker);

  /// Variant of [call] used for **streaming** RPCs. Defaults to [call] so most middleware behave
  /// identically for unary and streaming. Override when streaming needs different handling — e.g.
  /// the auth middleware must NOT replay-retry a streaming call, since the request `Stream` can't
  /// be re-listened (a retried `invoker` would throw `StateError`).
  GrpcMiddlewareHandler callStreaming(GrpcMiddlewareHandler invoker) => call(invoker);

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final holder = ResponseFutureHolder<R>();

    Future<R> execute() async {
      final handler = call((path, metadata) async {
        final mergedOptions = metadata.isEmpty ? options : options.mergedWith(CallOptions(metadata: metadata));
        final response = invoker(method, request, mergedOptions);
        holder.response = response;
        await response;
      });
      await handler(method.path, options.metadata);
      return holder.response!;
    }

    return HolderResponseFuture<R>(execute(), holder);
  }

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
  ) {
    final holder = _ResponseStreamHolder<R>();

    // Register cancellation BEFORE any async work starts, so an early unsubscribe (e.g. the screen
    // is popped before the underlying call is even created) still aborts it. If the response is not
    // yet set we record the intent; `execute` cancels the call the moment it exists (A17). Without
    // this, a cancel that arrives before `holder.response` is set was silently dropped and the
    // server-streaming RPC kept running until it completed or hit the stream deadline.
    final controller = StreamController<R>()..onCancel = () => (holder..cancelled = true).response?.cancel();

    Future<void> execute() async {
      final handler = callStreaming((path, metadata) async {
        final mergedOptions = metadata.isEmpty ? options : options.mergedWith(CallOptions(metadata: metadata));
        final response = invoker(method, requests, mergedOptions);

        // Publish the live call (so a concurrent onCancel can abort it) AND read the cancel flag in
        // one expression: the cascade assigns `response` first, then evaluates to `holder` whose
        // `cancelled` we check. If the consumer already unsubscribed before the call existed, abort.
        if ((holder..response = response).cancelled) {
          await response.cancel();
          return;
        }

        await for (final event in response) {
          if (!controller.isClosed) controller.add(event);
        }
      });

      try {
        await handler(method.path, options.metadata);
      } on Object catch (e, s) {
        if (!controller.isClosed) controller.addError(e, s);
      } finally {
        if (!controller.isClosed) await controller.close();
      }
    }

    execute();

    return _DeferredResponseStream<R>(controller.stream, holder);
  }
}

/// Holder for a streaming response. [cancelled] records a consumer unsubscribe that arrived before
/// [response] existed, so the call can be aborted as soon as it is created (A17).
class _ResponseStreamHolder<R> {
  ResponseStream<R>? response;
  bool cancelled = false;
}

/// Wraps a deferred [ResponseStream] that's initialized asynchronously. Extends [StreamView]
/// (like grpc's own ResponseStream) so every Stream method delegates automatically; only the
/// gRPC-specific members are overridden.
class _DeferredResponseStream<R> extends StreamView<R> implements ResponseStream<R> {
  const _DeferredResponseStream(super.stream, this._holder);

  final _ResponseStreamHolder<R> _holder;

  @override
  Future<Map<String, String>> get headers async =>
      _holder.response?.headers ?? Future<Map<String, String>>.value(const <String, String>{});

  @override
  Future<Map<String, String>> get trailers async =>
      _holder.response?.trailers ?? Future<Map<String, String>>.value(const <String, String>{});

  @override
  ResponseFuture<R> get single => _SingleResponseFuture<R>(super.single, _holder);

  @override
  Future<void> cancel() async => _holder.response?.cancel();
}

/// A [ResponseFuture] for the `single` getter — delegates the Future API via [DelegatingFuture]
/// and the gRPC metadata/cancel to the stream holder.
class _SingleResponseFuture<R> extends DelegatingFuture<R> implements ResponseFuture<R> {
  _SingleResponseFuture(super.future, this._holder);

  final _ResponseStreamHolder<R> _holder;

  @override
  Future<Map<String, String>> get headers async =>
      _holder.response?.headers ?? Future<Map<String, String>>.value(const <String, String>{});

  @override
  Future<Map<String, String>> get trailers async =>
      _holder.response?.trailers ?? Future<Map<String, String>>.value(const <String, String>{});

  @override
  Future<void> cancel() async => _holder.response?.cancel();
}
