import 'dart:async';

import 'package:async/async.dart';
import 'package:grpc/grpc.dart';

/// Tracks the in-flight [ResponseFuture] for a call whose real future is created asynchronously
/// (inside a middleware handler — see [HolderResponseFuture]). [cancel] aborts the in-flight
/// attempt; subclasses extend the policy (e.g. retry also stops its loop). Mirrors grpc's own
/// `ResponseFuture extends DelegatingFuture` design, so it is the single home for this pattern
/// shared by the base middleware and the retry middleware (deduplicated).
class ResponseFutureHolder<R> {
  ResponseFuture<R>? response;

  Future<void> cancel() async => response?.cancel();
}

/// A [ResponseFuture] whose underlying future settles later (the call is created inside an async
/// handler, but `interceptUnary` must return a [ResponseFuture] synchronously). Extends
/// [DelegatingFuture] (like grpc's own ResponseFuture) so the Future API delegates automatically;
/// the gRPC-specific `headers`/`trailers`/`cancel` delegate to [holder]'s current response.
class HolderResponseFuture<R> extends DelegatingFuture<R> implements ResponseFuture<R> {
  HolderResponseFuture(this._future, this.holder) : super(_future);

  final Future<R> _future;
  final ResponseFutureHolder<R> holder;

  @override
  Future<Map<String, String>> get headers async {
    try {
      await _future;
    } on Object {
      // Only need the response to settle; the error itself surfaces through `_future`.
    }
    return holder.response?.headers ?? Future<Map<String, String>>.value(const <String, String>{});
  }

  @override
  Future<Map<String, String>> get trailers async {
    try {
      await _future;
    } on Object {
      // As above.
    }
    return holder.response?.trailers ?? Future<Map<String, String>>.value(const <String, String>{});
  }

  @override
  Future<void> cancel() => holder.cancel();
}
