import 'dart:async';

import 'package:core_model/core_model.dart';
import 'package:http/http.dart' as http_package;
import 'package:meta/meta.dart';
import 'package:rest_client/src/api_client.dart';

/// Per-request override for the connect timeout (request → response headers).
/// Accepts a [Duration], an `int` of milliseconds, or an absolute [DateTime] deadline;
/// a zero/past value disables it. Falls back to the legacy [kTimeoutContextKey]/[kDurationContextKey].
const kConnectTimeoutContextKey = 'connect-timeout';

/// Per-request override for the receive timeout (max idle gap between body chunks).
/// Accepts a [Duration] or `int` milliseconds; a zero value disables it.
const kReceiveTimeoutContextKey = 'receive-timeout';

/// Legacy/alias per-request connect-timeout keys (same accepted value types as
/// [kConnectTimeoutContextKey]).
const kTimeoutContextKey = 'timeout';
const kDurationContextKey = 'duration';

/// {@template timeout_middleware}
/// Bounds a request with two independent timeouts (mirroring Dio):
/// - [connectTimeout] — time to receive the response **headers** (`.timeout()` on the send);
/// - [receiveTimeout] — max **idle** gap while the response body is being read (a steady
///   download never trips it; a stalled server does).
///
/// On either timeout the request's [CancelToken] is cancelled (aborting the socket) and an
/// [ApiClientException$Timeout] (HTTP 408) is surfaced.
/// {@endtemplate}
@immutable
class TimeoutMiddleware {
  /// {@macro timeout_middleware}
  const TimeoutMiddleware({
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.duration,
    this.onTimeout,
  });

  /// Time allowed to receive the response headers. Overridable per request via
  /// [kConnectTimeoutContextKey] (or the legacy `'timeout'`/`'duration'` context keys).
  final Duration connectTimeout;

  /// Max idle gap allowed between response-body chunks. Overridable per request via
  /// [kReceiveTimeoutContextKey].
  final Duration receiveTimeout;

  /// Back-compat alias for [connectTimeout]: when provided it overrides the connect default.
  final Duration? duration;

  /// Optional callback invoked with the elapsed limit when a timeout fires.
  final void Function(Duration duration)? onTimeout;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    final connect = _resolve(
      context[kConnectTimeoutContextKey] ?? context[kTimeoutContextKey] ?? context[kDurationContextKey],
      duration ?? connectTimeout,
    );
    final receive = _resolve(context[kReceiveTimeoutContextKey], receiveTimeout);

    // --- connect timeout: request → response headers ---
    final ApiClientResponse response;
    final inner = innerHandler(request, context);
    if (connect == null) {
      response = await inner;
    } else {
      try {
        response = await inner.timeout(connect);
      } on TimeoutException catch (e, s) {
        // Abort the underlying socket so it stops consuming bandwidth — `.timeout()` alone only
        // stops awaiting. The caller sees a timeout (not a cancellation) since we stopped awaiting.
        if (context[kCancelTokenContextKey] case final CancelToken token) token.cancel(e);
        onTimeout?.call(connect);
        Error.throwWithStackTrace(
          ApiClientException$Timeout(
            duration: connect,
            code: 'timeout',
            statusCode: 408, // HTTP 408 Request Timeout
            message: 'Request timed out after ${connect.inSeconds} seconds',
            error: e,
          ),
          s,
        );
      }
    }

    // --- receive timeout: idle gap while reading the body ---
    // Wrap the body stream with an idle timer; it fires only while the caller consumes the
    // body, so it never collides with RetryMiddleware (which has already returned by then).
    if (receive == null) return response;
    final wrapped = response.stream.timeout(
      receive,
      onTimeout: (sink) {
        if (context[kCancelTokenContextKey] case final CancelToken token) token.cancel();
        onTimeout?.call(receive);
        sink.addError(
          ApiClientException$Timeout(
            duration: receive,
            code: 'receive_timeout',
            statusCode: 408,
            message: 'No data received for ${receive.inSeconds} seconds',
          ),
        );
      },
    );
    return response.clone(stream: http_package.ByteStream(wrapped));
  };

  /// Resolves a context timeout value ([Duration] / `int` ms / [DateTime] deadline) to a
  /// [Duration], or `null` to disable. A missing/unknown value falls back to [fallback].
  static Duration? _resolve(Object? raw, Duration fallback) => switch (raw) {
    final Duration d when d > .zero => d,
    final int ms when ms > 0 => .new(milliseconds: ms),
    final DateTime d when d.isAfter(DateTime.now()) => d.difference(DateTime.now()).abs(),
    Duration() || int() || DateTime() => null, // explicit zero/past ⇒ disabled
    _ => fallback, // null/unknown ⇒ default
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
