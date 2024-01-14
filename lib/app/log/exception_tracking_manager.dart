// ignore_for_file: one_member_abstracts
import 'dart:async';

import 'package:auth_app/app/environment/model/environment.dart';
import 'package:auth_app/app/log/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// {@template error_tracking_manager}
/// A class which is responsible for enabling error tracking.
/// {@endtemplate}
abstract interface class IExceptionTrackingManager {
  /// Enables error tracking.
  ///
  /// This method should be called when the user has opted in to error tracking.
  Future<void> enableReporting();

  /// Disables error tracking.
  ///
  /// This method should be called when the user has opted out of error tracking
  Future<void> disableReporting();
}

/// {@template sentry_tracking_manager}
/// A class that is responsible for managing Sentry error tracking.
/// {@endtemplate}
abstract base class ExceptionTrackingManager implements IExceptionTrackingManager {
  final Logger _logger;
  StreamSubscription<LogMessage>? _subscription;

  /// Catch only warnings and errors
  Stream<LogMessage> get _reportLogs => _logger.logs.where(_isWarningOrError);

  /// {@macro sentry_tracking_manager}
  ExceptionTrackingManager(this._logger);

  @mustCallSuper
  @mustBeOverridden
  @override
  Future<void> disableReporting() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @mustCallSuper
  @mustBeOverridden
  @override
  Future<void> enableReporting() async {
    _subscription ??= _reportLogs.listen((log) async {
      if (_shouldReport(log.error)) {
        await _report(log);
      }
    });
  }

  static bool _isWarningOrError(LogMessage log) => log.level.compareTo(LogLevel.warning) >= 0;

  /// Returns `true` if the error should be reported.
  @pragma('vm:prefer-inline', 'dart2js:tryInline')
  bool _shouldReport(Object? error) => true;

  /// Handles the log message.
  ///
  /// This method is called when a log message is received.
  Future<void> _report(LogMessage log);
}

/// {@template sentry_tracking_manager}
/// A class that is responsible for managing Sentry error tracking.
/// {@endtemplate}
final class SentryTrackingManager extends ExceptionTrackingManager {
  /// The Sentry DSN.
  final String sentryDsn;

  /// The Sentry environment.
  final EnvironmentFlavor environment;

  /// {@macro sentry_tracking_manager}
  SentryTrackingManager({
    required this.sentryDsn,
    required this.environment,
    required Logger logger,
  }) : super(logger);

  @override
  Future<void> enableReporting() async {
    await SentryFlutter.init(
      (options) => options
        ..dsn = sentryDsn
        ..tracesSampleRate = 0.2 // Set the sample rate to 20% of events.
        ..debug = kDebugMode
        ..environment = environment.toString(),
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
    final error = log.error;
    final stackTrace = log.stackTrace;

    if (error == null && stackTrace == null && log.message is String) {
      await Sentry.captureMessage(log.message as String);
      return;
    }

    await Sentry.captureException(error ?? log.message, stackTrace: stackTrace);

    // final buffer = StringBuffer()..write(log.message);
    // if (log.error != null) {
    //   buffer.write('| ${log.error}');
    // }
    // await Sentry.captureException(
    //   buffer.toString(),
    //   stackTrace: log.stackTrace,
    // );
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
