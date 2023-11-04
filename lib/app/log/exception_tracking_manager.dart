// ignore_for_file: one_member_abstracts
import 'dart:async';

import 'package:auth_app/app/environment/model/environment.dart';
import 'package:auth_app/app/log/logger.dart';
import 'package:meta/meta.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// A class which is responsible for disabling error tracking.
abstract interface class IExceptionTrackingDisabler {
  /// Disables error tracking.
  ///
  /// This method should be called when the user has opted out of error tracking
  Future<void> disableReporting();
}

// abstract interface class ILogManager {
//   Future<void> log(String message, {StackTrace? stackTrace});
// }

abstract interface class IExceptionTrackingManager implements IExceptionTrackingDisabler {
  /// Enables error tracking.
  ///
  /// This method should be called when the user has opted in to error tracking.
  Future<void> enableReporting();
}

/// {@template exception_tracking_manager}
/// A class that is responsible for managing exception tracking.
/// {@endtemplate}
abstract base class ExceptionTrackingManager implements IExceptionTrackingManager {
  final Logger _log;
  StreamSubscription<LogMessage>? _subscription;

  /// Catch only warnings and errors
  Stream<LogMessage> get _reportLogs => _log.logs.where(_isWarningOrError);

  /// {@macro exception_tracking_manager}
  ExceptionTrackingManager({
    required Logger logger,
  }) : _log = logger;

  @override
  @mustCallSuper
  @mustBeOverridden
  Future<void> disableReporting() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  @mustCallSuper
  @mustBeOverridden
  Future<void> enableReporting() async {
    _subscription ??= _reportLogs.listen(_report);
  }

  static bool _isWarningOrError(LogMessage log) => switch (log.level) {
        LogLevel.shout || LogLevel.error || LogLevel.warning => true,
        _ => false,
      };

  /// Handles the log message.
  ///
  /// This method is called when a log message is received.
  Future<void> _report(LogMessage log);
}

/// {@template sentry_tracking_manager}
/// A class that is responsible for managing Sentry exceptions tracking.
/// {@endtemplate}
final class SentryTrackingManager extends ExceptionTrackingManager {
  final String _sentryDsn;
  final Environment _environment;

  /// {@macro sentry_tracking_manager}
  SentryTrackingManager({
    required Environment environment,
    required String sentryDsn,
    required super.logger,
  })  : _environment = environment,
        _sentryDsn = sentryDsn;

  @override
  Future<void> enableReporting() async {
    await SentryFlutter.init(
      (options) => options
        ..dsn = _sentryDsn
        ..environment = _environment.toString()
        ..tracesSampleRate = 1,
    );
    await super.enableReporting();
  }

  @override
  Future<void> disableReporting() async {
    await Sentry.close();
    await super.disableReporting();
  }

  @override
  Future<void> _report(LogMessage log) async {
    final buffer = StringBuffer()..write(log.message);
    if (log.error != null) {
      buffer.write('| ${log.error}');
    }
    await Sentry.captureException(
      buffer.toString(),
      stackTrace: log.stackTrace,
    );
  }

  // static Future<SentryId> _captureException(LogMessage msg) => Sentry.captureException(
  //       msg.message,
  //       stackTrace: msg.stackTrace != null //is LogMessageWithStackTrace
  //           ? <String, Object>{
  //               'stackTrace': Trace.from(msg.stackTrace!).toString(),
  //             }
  //           : null,
  //     );
  // static Future<void> _captureException(LogMessage msg) //
  //     =>
  //     Sentry.addBreadcrumb(
  //       Breadcrumb(
  //         message: msg.message.toString(),
  //         category: 'background.log',
  //         level: msg.level.when<SentryLevel>(
  //           shout: () => SentryLevel.info,
  //           v: () => SentryLevel.info,
  //           error: () => SentryLevel.error,
  //           vv: () => SentryLevel.info,
  //           warning: () => SentryLevel.warning,
  //           vvv: () => SentryLevel.info,
  //           info: () => SentryLevel.info,
  //           vvvv: () => SentryLevel.debug,
  //           debug: () => SentryLevel.debug,
  //           vvvvv: () => SentryLevel.debug,
  //           vvvvvv: () => SentryLevel.debug,
  //         ),
  //         timestamp: msg.date,
  //         data: msg is LogMessageWithStackTrace
  //             ? <String, Object>{
  //                 'stackTrace': Trace.from(msg.stackTrace).toString(),
  //               }
  //             : null,
  //       ),
  //     );
}
