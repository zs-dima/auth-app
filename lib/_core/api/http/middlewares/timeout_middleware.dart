import 'dart:async';

import 'package:auth_app/_core/api/http/api_client.dart';
import 'package:meta/meta.dart';

/// {@template timeout_middleware}
/// Throws an exception if the request takes longer than the specified duration.
/// [TimeoutMiddleware] middleware is useful for preventing requests from hanging indefinitely.
/// {@endtemplate}
@immutable
class TimeoutMiddleware {
  /// {@macro timeout_middleware}
  const TimeoutMiddleware({this.duration = const Duration(seconds: 30), this.onTimeout});

  /// Default timeout duration for API requests.
  final Duration duration;

  /// Optional callback that is called when a timeout occurs.
  final void Function(Duration duration)? onTimeout;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    final timeout = switch (context['timeout'] ?? context['duration']) {
      final Duration d when d > Duration.zero => d,
      final int ms when ms > 0 => Duration(milliseconds: ms),
      final DateTime d when d.isAfter(DateTime.now()) => d.difference(DateTime.now()).abs(),
      Duration() || int() || DateTime() => null, // Timeout should not be applied if the value is 0
      _ => duration, // No timeout specified
    };
    if (timeout == null) return innerHandler(request, context);
    try {
      return await innerHandler(request, context).timeout(timeout);
    } on TimeoutException catch (e, s) {
      onTimeout?.call(timeout);
      Error.throwWithStackTrace(
        ApiClientException$Timeout(
          duration: timeout,
          code: 'timeout',
          statusCode: 408, // HTTP 408 Request Timeout
          message: 'Request timed out after ${timeout.inSeconds} seconds',
          error: e,
        ),
        s,
      );
    }
  };
}

/// Client timeout exception.
/// This exception is thrown when a request times out.
final class ApiClientException$Timeout extends ApiClientException implements TimeoutException {
  const ApiClientException$Timeout({
    required this.code,
    required this.message,
    required this.statusCode,
    this.error,
    this.data,
    required this.duration,
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

  /// The duration that was exceeded.
  @override
  final Duration? duration;
}
