// The handler-based middleware API intentionally uses function-typedef parameters; suppress the
// matching style lints (deduplicated — A9).
// ignore_for_file: type_annotate_public_apis, avoid_dynamic, avoid-dynamic, prefer-explicit-parameter-names, use_function_type_syntax_for_parameters, prefer-async-callback, prefer-explicit-function-type

import 'dart:async';

import 'package:connectrpc/connect.dart';

typedef ConnectMiddlewareHandler = Future<void> Function(String path, Map<String, String> metadata);

/// Base class for Connect client middleware.
///
/// Provides a simplified API similar to HTTP middleware patterns, where you control the full
/// request/response flow in a single method. Satisfies connect-dart's [Interceptor] contract via
/// the generic [call], so instances register directly in a Transport's `interceptors:` list
/// (first in the list = outermost — pinned by the chain-order test).
abstract class ConnectMiddleware {
  /// Creates a Connect middleware instance.
  const ConnectMiddleware();

  /// Called for each unary RPC.
  ///
  /// Override this method to:
  /// - Add headers to `metadata` (e.g., authentication tokens)
  /// - Call `invoker` to proceed with the request
  /// - Handle errors from the response
  ///
  /// The `path` is the RPC method path (e.g., '/package.Service/Method').
  ///
  /// Example:
  /// ```dart
  /// ConnectMiddlewareHandler handle(ConnectMiddlewareHandler invoker) => (path, metadata) async {
  ///   metadata['Authorization'] = 'Bearer $token';
  ///   try {
  ///     await invoker(path, metadata);
  ///   } on ConnectException catch (e) {
  ///     // Handle error
  ///     rethrow;
  ///   }
  /// };
  /// ```
  ConnectMiddlewareHandler handle(ConnectMiddlewareHandler invoker);

  /// Variant of [handle] used for **streaming** RPCs. Defaults to [handle] so most middleware
  /// behave identically for unary and streaming. Override when streaming needs different handling
  /// — e.g. the auth middleware must NOT replay-retry a streaming call, since the request `Stream`
  /// can't be re-listened (a retried `invoker` would fail).
  ConnectMiddlewareHandler handleStreaming(ConnectMiddlewareHandler invoker) => handle(invoker);

  /// connect-dart [Interceptor] entry point (callable class): dispatches to the handler API,
  /// preserving its contract that the handler observes the *whole* call — for streams that
  /// includes every message and any mid-stream error.
  AnyFn<I, O> call<I extends Object, O extends Object>(AnyFn<I, O> next) =>
      (req) => switch (req) {
        UnaryRequest<I, O>() => _interceptUnary(req, next),
        StreamRequest<I, O>() => _interceptStreaming(req, next),
      };

  /// Canonical leading-slash `/package.Service/Method` form of a generated procedure name, so
  /// path sets (e.g. the public auth paths) match regardless of the codegen's slash convention
  /// (asserted against the generated specs by a test — A19).
  static String normalizePath(String procedure) => procedure.startsWith('/') ? procedure : '/$procedure';

  /// Snapshot of [headers] as a plain map (last value wins for multi-value headers — request
  /// metadata in this app is single-valued). NB: unlike the grpc-era handler metadata (custom
  /// entries only), the map also carries the protocol's transport headers (content-type,
  /// connect-protocol-version, connect-timeout-ms, user-agent, …) — handlers copy-and-extend, so
  /// this only widens what they (and Sentry's redacted `request_headers`) observe.
  static Map<String, String> headersToMap(Headers headers) => <String, String>{
    for (final header in headers.entries) header.name: header.value,
  };

  /// [base] with every entry of [metadata] applied on top (handler-provided keys win — the
  /// equivalent of the grpc-era `CallOptions.mergedWith` merge direction).
  static Headers mergedHeaders(Headers base, Map<String, String> metadata) {
    final headers = Headers.from(base);
    for (final entry in metadata.entries) {
      headers[entry.key] = entry.value;
    }
    return headers;
  }

  Future<Response<I, O>> _interceptUnary<I extends Object, O extends Object>(
    UnaryRequest<I, O> req,
    AnyFn<I, O> next,
  ) async {
    Response<I, O>? response;
    final handler = handle((path, metadata) async {
      final request = metadata.isEmpty
          ? req
          : UnaryRequest<I, O>(req.spec, req.url, mergedHeaders(req.headers, metadata), req.message, req.signal);
      response = await next(request);
    });
    await handler(normalizePath(req.spec.procedure), headersToMap(req.headers));
    return response ?? (throw StateError('ConnectMiddleware.handle completed without invoking the request'));
  }

  Future<Response<I, O>> _interceptStreaming<I extends Object, O extends Object>(
    StreamRequest<I, O> req,
    AnyFn<I, O> next,
  ) {
    final out = Completer<Response<I, O>>();
    final controller = StreamController<O>();
    // Child signal substituted into the forwarded request: cancelling it aborts the underlying
    // HTTP/2 stream (the transport races the request's signal), while the caller's own signal
    // still propagates through as the parent.
    final child = CancelableSignal(parent: req.signal);
    var cancelled = false;
    StreamSubscription<O>? sub;
    Completer<void>? done;

    // Register cancellation BEFORE any async work starts, so an early unsubscribe (e.g. the screen
    // is popped before the underlying call is even created) still aborts it. If the call is not
    // yet in flight we record the intent and the invoker checks the flag the moment it runs (A17).
    // NB: the caller-facing cancellation bridge is signal-based (guardRpcStream cancels its
    // per-call signal on unsubscribe); this onCancel covers in-chain teardown.
    controller.onCancel = () {
      cancelled = true;
      child.cancel();
      sub?.cancel().ignore();
      // Consumer walked away: let a still-waiting handler finish quietly (a signal-abort error
      // usually wins the race and surfaces as `canceled` instead).
      final pending = done;
      if (pending != null && !pending.isCompleted) pending.complete();
    };

    Future<void> execute() async {
      final handler = handleStreaming((path, metadata) async {
        if (cancelled) return; // consumer unsubscribed before the call existed — never start it (A17)
        final request = StreamRequest<I, O>(
          req.spec,
          req.url,
          metadata.isEmpty ? req.headers : mergedHeaders(req.headers, metadata),
          req.message,
          child,
        );
        final res = await next(request) as StreamResponse<I, O>;

        // Publish the response at header time (headers/trailers keep pointing at the live
        // response objects) so the caller can start consuming while this handler — and every
        // outer middleware — keeps observing the whole stream lifetime, mid-stream errors
        // included (repair-without-replay, Sentry spans, logging).
        if (!out.isCompleted) {
          out.complete(StreamResponse<I, O>(res.spec, res.headers, controller.stream, res.trailers));
        }

        final finished = done = Completer<void>();
        final subscription = res.message.listen(
          (event) {
            if (!controller.isClosed) controller.add(event);
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!finished.isCompleted) finished.completeError(error, stackTrace);
          },
          onDone: () {
            if (!finished.isCompleted) finished.complete();
          },
          cancelOnError: true,
        );
        sub = subscription;
        // Back-pressure: couple the consumer's pause/resume through to HTTP/2 flow control.
        controller
          ..onPause = subscription.pause
          ..onResume = subscription.resume;
        // Apply a pause missed before the call existed. hasListener matters: with no listener
        // isPaused is also true, and pausing then would freeze the source (listen ≠ onResume).
        if (controller.hasListener && controller.isPaused) subscription.pause();
        if (cancelled) {
          // Raced: the consumer cancelled while the call was being created — abort the pump.
          await subscription.cancel();
          return;
        }
        await finished.future; // the handler awaits the full stream; mid-stream errors surface here
      });

      try {
        await handler(normalizePath(req.spec.procedure), headersToMap(req.headers));
      } on Object catch (error, stackTrace) {
        if (!out.isCompleted) {
          // Failed before response headers — surface as a failure of the call itself (unary-like).
          out.completeError(error, stackTrace);
        } else if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      } finally {
        if (!out.isCompleted) {
          // Handler returned without invoking (early-cancel / no-op): empty stream, closed below.
          out.complete(StreamResponse<I, O>(req.spec, Headers(), controller.stream, Headers()));
        }
        if (!controller.isClosed) await controller.close();
      }
    }

    unawaited(execute());

    return out.future;
  }
}
