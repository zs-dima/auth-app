// ignore_for_file: type_annotate_public_apis, avoid_dynamic, prefer-explicit-parameter-names, avoid-dynamic, use_function_type_syntax_for_parameters, use_function_type_syntax_for_parameters, use_function_type_syntax_for_parameters

import 'dart:async';

import 'package:grpc/grpc.dart';

typedef ApiClientHandler = Future<void> Function(String path, Map<String, String> metadata);

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
  // Future<void> call(
  //   String path,
  //   ApiClientHandler invoker,
  // );
  ApiClientHandler call(ApiClientHandler invoker);

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final holder = _ResponseFutureHolder<R>();

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

    return _DeferredResponseFuture<R>(execute(), holder);
  }

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
  ) {
    final holder = _ResponseStreamHolder<R>();
    final controller = StreamController<R>();

    Future<void> execute() async {
      final handler = call((path, metadata) async {
        final mergedOptions = metadata.isEmpty ? options : options.mergedWith(CallOptions(metadata: metadata));
        final response = invoker(method, requests, mergedOptions);
        holder.response = response;

        await for (final event in response) {
          controller.add(event);
        }
      });

      try {
        await handler(method.path, options.metadata);
      } on Object catch (e, s) {
        controller.addError(e, s);
      } finally {
        await controller.close();
      }
    }

    execute();

    controller.onCancel = () => holder.response?.cancel();

    return _DeferredResponseStream<R>(controller.stream, holder);
  }
}

/// Holder for a response that may be set asynchronously.
class _ResponseFutureHolder<R> {
  ResponseFuture<R>? response;
}

/// Holder for a streaming response.
class _ResponseStreamHolder<R> {
  ResponseStream<R>? response;
}

/// Wraps a deferred [ResponseFuture] that's initialized asynchronously.
class _DeferredResponseFuture<R> implements ResponseFuture<R> {
  const _DeferredResponseFuture(this._future, this._holder);

  final Future<R> _future;
  final _ResponseFutureHolder<R> _holder;

  @override
  Future<Map<String, String>> get headers async {
    try {
      await _future;
    } on Object {
      // Ignore - we just need to wait for the response to be available
    }
    return _holder.response?.headers ?? Future<Map<String, String>>.value(const <String, String>{});
  }

  @override
  Future<Map<String, String>> get trailers async {
    try {
      await _future;
    } on Object {
      // Ignore
    }
    return _holder.response?.trailers ?? Future<Map<String, String>>.value(const <String, String>{});
  }

  @override
  Future<void> cancel() async => _holder.response?.cancel();

  @override
  Stream<R> asStream() => Stream<R>.fromFuture(_future);

  @override
  Future<R> catchError(Function onError, {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);

  @override
  Future<S> then<S>(FutureOr<S> Function(R value) onValue, {Function? onError}) =>
      _future.then(onValue, onError: onError);

  @override
  Future<R> whenComplete(FutureOr<void> Function() action) => _future.whenComplete(action);

  @override
  Future<R> timeout(Duration timeLimit, {FutureOr<R> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);
}

/// Wraps a deferred [ResponseStream] that's initialized asynchronously.
class _DeferredResponseStream<R> implements ResponseStream<R> {
  const _DeferredResponseStream(this._stream, this._holder);

  final Stream<R> _stream;
  final _ResponseStreamHolder<R> _holder;

  @override
  Future<Map<String, String>> get headers async =>
      _holder.response?.headers ?? Future<Map<String, String>>.value(const <String, String>{});

  @override
  Future<Map<String, String>> get trailers async =>
      _holder.response?.trailers ?? Future<Map<String, String>>.value(const <String, String>{});

  @override
  Future<R> get first => _stream.first;

  @override
  bool get isBroadcast => _stream.isBroadcast;

  @override
  Future<bool> get isEmpty => _stream.isEmpty;

  @override
  Future<R> get last => _stream.last;

  @override
  Future<int> get length => _stream.length;

  @override
  ResponseFuture<R> get single => _SingleResponseFuture<R>(_stream.single);

  @override
  Future<void> cancel() async => _holder.response?.cancel();

  @override
  StreamSubscription<R> listen(
    void Function(R event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => _stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  // Delegate all Stream methods to the underlying stream
  @override
  Future<bool> any(bool Function(R element) test) => _stream.any(test);

  @override
  Stream<R> asBroadcastStream({
    void Function(StreamSubscription<R> subscription)? onListen,
    void Function(StreamSubscription<R> subscription)? onCancel,
  }) => _stream.asBroadcastStream(onListen: onListen, onCancel: onCancel);

  @override
  Stream<E> asyncExpand<E>(Stream<E>? Function(R event) convert) => _stream.asyncExpand(convert);

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(R event) convert) => _stream.asyncMap(convert);

  @override
  Stream<S> cast<S>() => _stream.cast<S>();

  @override
  Future<bool> contains(Object? needle) => _stream.contains(needle);

  @override
  Stream<R> distinct([bool Function(R previous, R next)? equals]) => _stream.distinct(equals);

  @override
  Future<E> drain<E>([E? futureValue]) => _stream.drain(futureValue);

  @override
  Future<R> elementAt(int index) => _stream.elementAt(index);

  @override
  Future<bool> every(bool Function(R element) test) => _stream.every(test);

  @override
  Stream<S> expand<S>(Iterable<S> Function(R element) convert) => _stream.expand(convert);

  @override
  Future<R> firstWhere(bool Function(R element) test, {R Function()? orElse}) =>
      _stream.firstWhere(test, orElse: orElse);

  @override
  Future<S> fold<S>(S initialValue, S Function(S previous, R element) combine) => _stream.fold(initialValue, combine);

  @override
  Future<void> forEach(void Function(R element) action) => _stream.forEach(action);

  @override
  Stream<R> handleError(Function onError, {bool test(error)?}) => _stream.handleError(onError, test: test);

  @override
  Future<String> join([String separator = '']) => _stream.join(separator);

  @override
  Future<R> lastWhere(bool Function(R element) test, {R Function()? orElse}) => _stream.lastWhere(test, orElse: orElse);

  @override
  Stream<S> map<S>(S Function(R event) convert) => _stream.map(convert);

  @override
  Future<dynamic> pipe(StreamConsumer<R> streamConsumer) => _stream.pipe(streamConsumer);

  @override
  Future<R> reduce(R Function(R previous, R element) combine) => _stream.reduce(combine);

  @override
  Future<R> singleWhere(bool Function(R element) test, {R Function()? orElse}) =>
      _stream.singleWhere(test, orElse: orElse);

  @override
  Stream<R> skip(int count) => _stream.skip(count);

  @override
  Stream<R> skipWhile(bool Function(R element) test) => _stream.skipWhile(test);

  @override
  Stream<R> take(int count) => _stream.take(count);

  @override
  Stream<R> takeWhile(bool Function(R element) test) => _stream.takeWhile(test);

  @override
  Stream<R> timeout(Duration timeLimit, {void Function(EventSink<R> sink)? onTimeout}) =>
      _stream.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<List<R>> toList() => _stream.toList();

  @override
  Future<Set<R>> toSet() => _stream.toSet();

  @override
  Stream<S> transform<S>(StreamTransformer<R, S> streamTransformer) => _stream.transform(streamTransformer);

  @override
  Stream<R> where(bool Function(R event) test) => _stream.where(test);
}

/// A simple ResponseFuture wrapper for the single getter.
class _SingleResponseFuture<R> implements ResponseFuture<R> {
  const _SingleResponseFuture(this._future);

  final Future<R> _future;

  @override
  Future<Map<String, String>> get headers async => const <String, String>{};

  @override
  Future<Map<String, String>> get trailers async => const <String, String>{};

  @override
  Future<void> cancel() async {}

  @override
  Stream<R> asStream() => Stream<R>.fromFuture(_future);

  @override
  Future<R> catchError(Function onError, {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);

  @override
  Future<S> then<S>(FutureOr<S> Function(R value) onValue, {Function? onError}) =>
      _future.then(onValue, onError: onError);

  @override
  Future<R> whenComplete(FutureOr<void> Function() action) => _future.whenComplete(action);

  @override
  Future<R> timeout(Duration timeLimit, {FutureOr<R> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);
}
