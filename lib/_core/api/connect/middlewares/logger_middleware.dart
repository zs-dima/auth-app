import 'dart:developer' as developer;

import 'package:auth_app/_core/api/_core/transport_log.dart';
import 'package:auth_app/_core/log/logger.dart';
import 'package:connect_model/connect_model.dart';
import 'package:connectrpc/connect.dart';
import 'package:meta/meta.dart';

/// {@template connect_logger_middleware}
/// Logs each call's path, outcome and duration. Place it early in the pipeline (outermost)
/// so it still sees changes made by later interceptors.
/// {@endtemplate}
@immutable
class ConnectLoggerMiddleware extends ConnectMiddleware {
  /// {@macro connect_logger_middleware}
  const ConnectLoggerMiddleware({this.logRequest = false, this.logResponse = true, this.logError = true});

  final bool logRequest;
  final bool logResponse;
  final bool logError;

  @override
  ConnectMiddlewareHandler handle(ConnectMiddlewareHandler invoker) => (path, metadata) async {
    final stopwatch = Stopwatch()..start();
    try {
      if (logRequest) {
        developer.log(path, name: 'Connect', time: DateTime.now(), level: 300);
      }
      await invoker(path, metadata);
      if (logResponse) {
        logger.v4(formatTransportLog(subject: path, outcome: 'success', elapsedMs: stopwatch.elapsedMilliseconds));
      }
    } on Object catch (e, s) {
      if (logError) {
        logger.w(
          formatTransportLog(
            subject: path,
            outcome: switch (e) {
              // Code name (e.g. `unavailable`) — the grpc-era logger printed the raw status int.
              ConnectException(:final code) => code.name,
              _ => 'error',
            },
            elapsedMs: stopwatch.elapsedMilliseconds,
          ),
          stackTrace: s,
        );
      }
      rethrow;
    } finally {
      stopwatch.stop();
    }
  };
}
