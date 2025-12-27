import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc_model/src/middleware/grpc_middleware.dart';
import 'package:meta/meta.dart';

/// {@template grpc_timeout_middleware}
/// Middleware for setting request timeouts.
///
/// Throws a [GrpcClientException$Timeout] if the request exceeds the specified duration.
/// The timeout can be overridden per-request via context.
/// {@endtemplate}
@immutable
class GrpcTimeoutMiddleware extends GrpcMiddlewareBase {
  /// {@macro grpc_timeout_middleware}
  const GrpcTimeoutMiddleware({this.duration = const Duration(seconds: 30), this.onTimeout});

  /// Default timeout duration for gRPC requests.
  final Duration duration;

  /// Optional callback invoked when a timeout occurs.
  final void Function(Duration duration)? onTimeout;

  @override
  GrpcHandler<Q, R> call<Q, R>(GrpcHandler<Q, R> next) => (request, context) async {
    final timeout = _resolveTimeout(context);
    if (timeout == null) return next(request, context);

    final updatedOptions = request.options.mergedWith(CallOptions(timeout: timeout));
    try {
      return await next(request.copyWith(options: updatedOptions), context).timeout(timeout);
    } on TimeoutException catch (e, s) {
      onTimeout?.call(timeout);
      Error.throwWithStackTrace(
        GrpcClientException$Timeout(
          code: 'timeout',
          message: 'Request timed out after ${timeout.inSeconds} seconds',
          statusCode: StatusCode.deadlineExceeded,
          error: e,
          duration: timeout,
        ),
        s,
      );
    }
  };

  Duration? _resolveTimeout(GrpcContext context) => switch (context['timeout'] ?? context['duration']) {
    final Duration d when d > Duration.zero => d,
    final int ms when ms > 0 => Duration(milliseconds: ms),
    final DateTime d when d.isAfter(DateTime.now()) => d.difference(DateTime.now()).abs(),
    Duration() || int() || DateTime() => null, // Zero/negative means no timeout
    _ => duration,
  };
}
