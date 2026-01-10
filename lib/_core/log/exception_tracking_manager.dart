// ignore_for_file: one_member_abstracts
import 'dart:async';

import 'package:auth_app/_core/environment/model/environment.dart';
import 'package:auth_app/_core/log/logger.dart';
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
  /// {@macro sentry_tracking_manager}
  ExceptionTrackingManager(this._logger);

  final Logger _logger;
  StreamSubscription<LogMessage>? _subscription;

  /// Catch only warnings and errors
  Stream<LogMessage> get _reportLogs => _logger.logs.where(_isWarningOrError);

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
    _subscription ??= _reportLogs.listen(
      (log) async {
        if (_shouldReport(log.error)) {
          await _report(log);
        }
      },
      cancelOnError: false,
    );
  }

  static bool _isWarningOrError(LogMessage log) => log.level.compareTo(.warning) >= 0;

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
  /// {@macro sentry_tracking_manager}
  SentryTrackingManager({
    required this.sentryDsn,
    required this.environment,
    required Logger logger,
  }) : super(logger);

  /// The Sentry DSN.
  final String sentryDsn;

  /// The Sentry environment.
  final EnvironmentFlavor environment;

  @override
  Future<void> enableReporting() async {
    await SentryFlutter.init(
      (options) => options
        ..dsn = sentryDsn
        ..tracesSampleRate =
            0.2 // Set the sample rate to 20% of events.
        ..debug = kDebugMode
        ..environment = environment.value,
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

// TODO: firebase exceptions
// String _firebaseExceptionToString(FirebaseException error) => switch (error.code.split('/').last.trim().toLowerCase()) {
//   "admin-restricted-operation" => "This operation is restricted to administrators only.",
//   "argument-error" => "The argument provided is invalid.",
//   "app-not-authorized" =>
//     "This app, identified by the domain where it's hosted, is not authorized to use with the provided API key.",
//   "app-not-installed" =>
//     "The requested mobile application corresponding to the identifier (Android package name or iOS bundle ID) provided is not installed on the device.",
//   "captcha-check-failed" =>
//     "The reCAPTCHA response token provided is either invalid, expired, already used or the domain associated with it does not match the domain of the app.",
//   "code-expired" => "The SMS code has expired. Please re-send the verification code to try again.",
//   "cordova-not-ready" => "Cordova framework is not ready.",
//   "cors-unsupported" => "This browser is not supported.",
//   "credential-already-in-use" => "This credential is already associated with a different user account.",
//   "custom-token-mismatch" => "The custom token corresponds to a different audience.",
//   "requires-recent-login" =>
//     "This operation is sensitive and requires recent authentication. Log in again before retrying this request.",
//   "dynamic-link-not-activated" => "Please activate Dynamic Links and agree to the terms and conditions.",
//   "email-change-needs-verification" => "Multi-factor users must always have a verified email.",
//   "email-already-in-use" =>
//     "Email is either in use or the password is incorrect. You can reset your password or try again.",
//   "expired-action-code" => "The action code has expired.",
//   "cancelled-popup-request" => "This operation has been cancelled due to another conflicting popup being opened.",
//   "internal-error" => "An internal error has occurred.",
//   "invalid-app-credential" =>
//     "The phone verification request contains an invalid application verifier. The reCAPTCHA token response is either invalid or expired.",
//   "invalid-app-id" => "The mobile app identifier is not registered for the current project.",
//   "invalid-user-token" =>
//     "This user's credential isn't valid for this project. This can happen if the user's token has been tampered with, or if the user's account has been deleted.",
//   "invalid-auth-event" => "An internal error has occurred.",
//   "invalid-verification-code" =>
//     "The SMS verification code used to create the phone auth credential is invalid. Please resend the verification code ms and be sure the verification code matches the one sent to the user's device.",
//   "invalid-continue-uri" => "The continue URL provided in the request is invalid.",
//   "invalid-cordova-configuration" => "The plugins must be installed to enable OAuth sign-in.",
//   "invalid-custom-token" => "The custom token format is incorrect. Please check the documentation.",
//   "invalid-dynamic-link-domain" =>
//     "The provided dynamic link domain is not configured or authorized for the current project.",
//   "invalid-email" => "The email address is badly formatted.",
//   "invalid-api-key" => "Your API key is invalid, please check you have copied it correctly.",
//   "invalid-cert-hash" => "The SHA-1 certificate hash provided is invalid.",
//   "invalid-credential" => "The supplied auth credential is malformed or has expired.",
//   "invalid-message-payload" =>
//     "The email template corresponding to this action contains invalid characters in its message.",
//   "invalid-multi-factor-session" => "The request does not contain a valid proof of first factor successful sign-in.",

//   // ***
// };
