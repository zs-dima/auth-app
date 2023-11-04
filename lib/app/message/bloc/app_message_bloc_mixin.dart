import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:auth_app/app/app.dart';
import 'package:auth_app/app/log/logger.dart';
import 'package:grpc/grpc.dart';

mixin AppMessageBlocMixin {
  late final AppMessageBloc _messageBloc;
  late final Logger _log;

  set messageBloc(AppMessageBloc messageBloc) {
    _messageBloc = messageBloc;
    _log = logger;
  }

  void emitMessage(String message, [Color? backgroundColor]) {
    _messageBloc.add(MessageEvent.showAppMessage(message, backgroundColor: backgroundColor));
  }

  void emitError(
    String message, [
    Object? e,
    StackTrace? s,
    void Function(String message)? onError,
  ]) {
    final msg = formatMessage(message);

    e is GrpcError //
        ? _emitNetError(msg, e)
        : _emitAppError(msg, e, s);
    onError?.call(msg);
  }

  void _emitAppError(
    String message, [
    Object? e,
    StackTrace? s,
  ]) {
    _log.e('$message: $e\n$s', stackTrace: s);
    _messageBloc.add(MessageEvent.showAppError(message));
  }

  void _emitNetError(
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
    _messageBloc.add(MessageEvent.showNetError(error, message));
  }

  void emitProgress(MessageEvent progress) => _messageBloc.add(progress);

  /// Rethrows the error with the stack trace.
  static Never throwWithStackTrace(Object error, StackTrace stackTrace) => Error.throwWithStackTrace(error, stackTrace);

  @pragma('vm:prefer-inline')
  static String _localizedError(String fallback, String Function(Localization l) localize) =>
      Localization.current == null ? fallback : localize(Localization.current!);

  // Also we can add current localization to this method
  static String formatMessage(
    Object error, [
    String fallback = 'An error has occurred',
  ]) =>
      switch (error) {
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
