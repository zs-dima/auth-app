import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:l/l.dart' as logging;

/// Logger instance
final logger = AppLogger$L();

/// Possible levels of logging
enum LogLevel implements Comparable<LogLevel> {
  /// Shout level
  shout._(1200),

  /// Error level
  error._(1000),

  /// Warning level
  warning._(800),

  /// Info level
  info._(600),

  /// Debug level
  debug._(400),

  /// Verbose level
  verbose._(200);

  const LogLevel._(this.value);

  /// Value of the level
  final int value;

  @override
  int compareTo(LogLevel other) => value.compareTo(other.value);

  @override
  String toString() => '$LogLevel($value)';
}

/// {@template log_options}
/// Options for the logger
/// {@endtemplate}
base class LogOptions {
  /// Log level
  final LogLevel level;

  /// Whether to show time
  final bool showTime;

  /// Whether to show emoji
  final bool showEmoji;

  /// Whether to log in release mode
  final bool logInRelease;

  /// Print with colors using ASCII escape codes
  final bool printColors;

  /// {@macro log_options}
  const LogOptions({
    this.showTime = true,
    this.showEmoji = false,
    this.logInRelease = false,
    this.printColors = false,
    this.level = LogLevel.info,
  });
}

/// {@template log_message}
/// Log message
/// {@endtemplate}
base class LogMessage {
  /// Log message
  final String message;

  final String? hint;
  final Object? error;
  final Object? data;

  /// Stack trace
  final StackTrace? stackTrace;

  /// Time of the log
  final DateTime? time;

  /// Log level
  final LogLevel level;

  /// {@macro log_message}
  const LogMessage({
    required this.message,
    required this.level,
    this.hint,
    this.error,
    this.stackTrace,
    this.time,
    this.data,
  });
}

/// Logger interface
abstract base class Logger {
  /// Stream of logs
  Stream<LogMessage> get logs;

  /// Logs the error to the console
  void e(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? hint,
    Object? data,
  });

  /// Logs the warning to the console
  void w(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? hint,
    Object? data,
  });

  /// Logs the info to the console
  void i(
    String message, {
    String? hint,
    Object? data,
  });

  /// Logs the debug to the console
  void d(String message);

  /// Logs the verbose to the console
  void v(String message);
  void v2(String message);
  void v3(String message);
  void v4(String message);
  void v5(String message);
  void v6(String message);

  /// Set up the logger
  L runLogging<L>(
    ValueGetter<L> fn, [
    LogOptions options = const LogOptions(),
  ]);

  /// Handy method to log zoneError
  void logZoneError(Object error, StackTrace stackTrace) {
    e('Top-level error: $error $stackTrace', stackTrace: stackTrace);
  }

  /// Handy method to log [FlutterError]
  void logFlutterError(FlutterErrorDetails details) {
    final stackTrace = details.stack ?? StackTrace.current;
    e('Flutter error: ${details.exceptionAsString()} $stackTrace', stackTrace: stackTrace);
  }

  /// Handy method to log [PlatformDispatcher] error
  bool logPlatformDispatcherError(Object error, StackTrace stackTrace) {
    e('PlatformDispatcher error: $error', stackTrace: stackTrace);
    return true;
  }
}

/// Default logger using logging package
final class AppLogger$L extends Logger {
  final _log = logging.l;

  final _logController = StreamController<LogMessage>.broadcast();

  @override
  Stream<LogMessage> get logs => _logController.stream;

  @override
  L runLogging<L>(
    ValueGetter<L> fn, [
    LogOptions options = const LogOptions(),
  ]) {
    if (kReleaseMode && !options.logInRelease) {
      return fn();
    }

    /// Formats the logger message
    ///
    /// Combines emoji, time and message
    String formatLoggerMessage(
      Object message,
      logging.LogLevel level,
      DateTime time,
    ) {
      final buffer = StringBuffer();
      if (options.showTime) {
        buffer
          ..write(time.formatted)
          ..write(' ')
          ..write(level.splitter)
          ..write(' ');
      }
      if (options.showEmoji) {
        buffer
          ..write(level.emoji)
          ..write(' ');
      }
      buffer.writeln(message);

      return buffer.toString();
    }

    final logOptions = logging.LogOptions(
      printColors: kDebugMode,
      handlePrint: true,
      outputInRelease: options.logInRelease,
      messageFormatting: formatLoggerMessage,
    );

    return _log.capture(fn, logOptions);
  }

  @override
  void e(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? hint,
    Object? data,
  }) {
    _log.e(message, stackTrace);
    _logController.add(
      LogMessage(
        message: message,
        error: error,
        stackTrace: stackTrace,
        level: LogLevel.error,
        hint: hint,
        data: data,
      ),
    );
  }

  @override
  void w(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? hint,
    Object? data,
  }) {
    _log.w(message, stackTrace);
    _logController.add(
      LogMessage(
        message: message,
        error: error,
        stackTrace: stackTrace,
        level: LogLevel.warning,
        hint: hint,
        data: data,
      ),
    );
  }

  @override
  void i(
    String message, {
    String? hint,
    Object? data,
  }) {
    _log.i(message);
    _logController.add(
      LogMessage(
        message: message,
        level: LogLevel.info,
        hint: hint,
        data: data,
      ),
    );
  }

  @override
  void d(String message) => _log.d(message);
  @override
  void v(String message) => _log.v(message);
  @override
  void v2(String message) => _log.vv(message);
  @override
  void v3(String message) => _log.vvv(message);
  @override
  void v4(String message) => _log.vvvv(message);
  @override
  void v5(String message) => _log.vvvvv(message);
  @override
  void v6(String message) => _log.vvvvvv(message);
}

extension on logging.LogLevel {
  /// Transforms [logging.LogLevel] to [LogLevel]
  // LogLevel toLogLevel() => maybeWhen(
  //       shout: () => LogLevel.shout,
  //       error: () => LogLevel.error,
  //       warning: () => LogLevel.warning,
  //       info: () => LogLevel.info,
  //       debug: () => LogLevel.debug,
  //       orElse: () => LogLevel.verbose,
  //     );

  /// Transforms [LogLevel] to emoji
  String get emoji => maybeWhen(
        shout: () => '❗️',
        error: () => '🚫',
        warning: () => '⚠️',
        info: () => '💡',
        debug: () => '🐞',
        orElse: () => '',
      );

  String get splitter => kDebugMode
      ? maybeWhen(
          shout: () => '\x1B[31m|\x1B[0m',
          error: () => '\x1B[31m|\x1B[0m',
          warning: () => '\x1B[33m|\x1B[0m',
          info: () => '\x1B[32m|\x1B[0m',
          debug: () => '\x1B[36m|\x1B[0m',
          orElse: () => '|',
        )
      : '|';
}

// extension on LogLevel {
//   /// Transforms [LogLevel] to [logging.LogLevel]
//   logging.LogLevel toLogLevel() => switch (this) {
//         LogLevel.shout => const logging.LogLevel.shout(),
//         LogLevel.error => const logging.LogLevel.error(),
//         LogLevel.warning => const logging.LogLevel.warning(),
//         LogLevel.info => const logging.LogLevel.info(),
//         _ => const logging.LogLevel.debug(),
//       };

//   /// Transforms [LogLevel] to emoji
//   String get emoji => switch (this) {
//         LogLevel.shout => '❗️',
//         LogLevel.error => '🚫',
//         LogLevel.warning => '⚠️',
//         LogLevel.info => '💡',
//         LogLevel.debug => '🐞',
//         _ => '',
//       };

//   String get splitter => kDebugMode
//       ? switch (this) {
//           LogLevel.shout || LogLevel.error => '\x1B[31m|\x1B[0m',
//           LogLevel.warning => '\x1B[33m|\x1B[0m',
//           LogLevel.info => '\x1B[32m|\x1B[0m',
//           LogLevel.debug => '\x1B[36m|\x1B[0m',
//           _ => '|',
//         }
//       : '|';
// }

extension on DateTime {
  /// Transforms DateTime to String with format: 00:00:00
  String get formatted => [
        if (!kDebugMode) hour,
        minute,
        second,
      ].map((i) => i.toString().padLeft(2, '0')).join(':');
}
