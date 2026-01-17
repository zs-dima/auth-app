import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:auth_app/_core/api/http/api_client.dart';
import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_app/_core/log/logger.dart';
import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/protos.dart';

typedef AppMessageBlocErrorCallback = void Function(String message);
typedef AppMessageBlocLocalizeErrorCallback = String Function(Localization l);

mixin AppMessageControllerMixin {
  late final AppMessageController _messageController;
  late final Logger _log;

  set messageController(AppMessageController value) {
    _messageController = value;
    _log = logger;
  }

  void setMessage(String message, [Color? backgroundColor]) {
    _messageController.showAppMessage(message, backgroundColor);
  }

  void setError(String message, [Object? e, StackTrace? s, AppMessageBlocErrorCallback? onError]) {
    final msg = formatMessage(message);

    switch (e) {
      case GrpcError _:
        _setGrpcError(msg, e);
        break;

      case ApiClientException _:
        _setApiError(msg, e, s);
        break;

      default:
        _setAppError(msg, e, s);
    }

    onError?.call(msg);
  }

  void _setAppError(String message, [Object? e, StackTrace? s]) {
    _log.e('$message: $e\n$s', stackTrace: s);
    _messageController.showAppError(message, e);
  }

  void _setGrpcError(
    String message,
    GrpcError error, [
    StackTrace? s,
  ]) {
    if (error.code == StatusCode.internal) {
      _log.e('gRPC Error: $message: ${error.message}', stackTrace: s);
    } else if (error.code == StatusCode.unknown && (error.message?.contains('CORS') ?? false)) {
      _log.e('gRPC CORS Error: $message: ${error.message}', stackTrace: s);
    } else {
      _log.e('gRPC Error: $message\n$error', stackTrace: s);
    }

    final details = error.details;
    if (details != null) {
      for (final detail in details) {
        if (detail is DebugInfo) {
          _log.w(detail);
        }
      }
    }

    _messageController.showGrpcError(error, message);
  }

  void _setApiError(String message, ApiClientException error, [StackTrace? s]) {
    _log.e('API Error: $message\n$error', stackTrace: s);
    _messageController.showApiError(error, message);
  }

  void setProgressStarted() => _messageController.progressStarted();
  void setProgressDone() => _messageController.progressDone();

  /// Rethrows the error with the stack trace.
  static Never throwWithStackTrace(Object error, StackTrace stackTrace) => Error.throwWithStackTrace(error, stackTrace);

  @pragma('dart2js:tryInline')
  @pragma('vm:prefer-inline')
  static String _localizedError(String fallback, AppMessageBlocLocalizeErrorCallback localize) =>
      Localization.current == null ? fallback : localize(Localization.current!);

  // Also we can add current localization to this method
  static String formatMessage(Object error, [String fallback = 'An error has occurred']) => switch (error) {
    final String e => e,
    FormatException _ => _localizedError('Invalid format', (lcl) => lcl.errInvalidFormat),
    TimeoutException _ => _localizedError('Timeout exceeded', (lcl) => lcl.errTimeOutExceeded),
    UnimplementedError _ => _localizedError('Not implemented yet', (lcl) => lcl.errNotImplementedYet),
    UnsupportedError _ => _localizedError('Unsupported operation', (lcl) => lcl.errUnsupportedOperation),
    FileSystemException _ => _localizedError('File system error', (lcl) => lcl.errFileSystemException),
    AssertionError _ => _localizedError('Assertion error', (lcl) => lcl.errAssertionError),
    Error _ => _localizedError('An error has occurred', (lcl) => lcl.errAnErrorHasOccurred),
    Exception _ => _localizedError('An exception has occurred', (lcl) => lcl.errAnExceptionHasOccurred),
    _ => fallback,
  };
}

extension GrpcErrorX on GrpcError {
  String detail(String caption) {
    switch (code) {
      case StatusCode.unauthenticated:
        final shortMessage = message;
        if (shortMessage?.isNotEmpty ?? false) return '$caption. $shortMessage';
        return caption;

      case StatusCode.permissionDenied:
        return '$caption: Permission denied';

      case StatusCode.unavailable:
        return 'Backend unavailable. Please contact support'; // '$caption: GRPC unavailable';

      case StatusCode.aborted:
        return '$caption: Network request aborted';

      case StatusCode.dataLoss:
        return '$caption: Network data loss';

      case StatusCode.deadlineExceeded:
        return 'Backend error. Please contact support'; // '$caption: GRPC deadline exceeded';

      case StatusCode.cancelled:
        return '$caption: Network request cancelled';

      case StatusCode.internal:
        return '$caption: $message';

      case StatusCode.failedPrecondition:
        return '$caption: Network request failed precondition';

      case StatusCode.unknown:
        if (message?.contains('CORS') ?? false) return '$caption: CORS error';
    }

    return '$caption: Network error: $this';
  }
}
