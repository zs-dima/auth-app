import 'dart:developer' as developer;

import 'package:auth_app/_core/api/_core/transport_log.dart';
import 'package:auth_app/_core/log/logger.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_model/grpc_model.dart';
import 'package:meta/meta.dart';

/// {@template grpc_logger_middleware}
/// Logs each call's path, outcome and duration. Place it early in the pipeline (outermost)
/// so it still sees changes made by later interceptors.
/// {@endtemplate}
@immutable
class GrpcLoggerMiddleware extends GrpcMiddleware {
  /// {@macro grpc_logger_middleware}
  const GrpcLoggerMiddleware({this.logRequest = false, this.logResponse = true, this.logError = true});

  final bool logRequest;
  final bool logResponse;
  final bool logError;

  @override
  GrpcMiddlewareHandler call(GrpcMiddlewareHandler invoker) => (path, metadata) async {
    final stopwatch = Stopwatch()..start();
    try {
      if (logRequest) {
        developer.log(path, name: 'gRPC', time: DateTime.now(), level: 300);
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
              GrpcError(:final code) => '$code',
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
