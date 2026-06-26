import 'dart:developer' as developer;

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
  ApiClientHandler call(ApiClientHandler invoker) => (path, metadata) async {
    final stopwatch = Stopwatch()..start();
    try {
      if (logRequest) {
        developer.log(path, name: 'gRPC', time: DateTime.now(), level: 300);
      }
      await invoker(path, metadata);
      if (logResponse) {
        logger.v4(
          '🌍 '
          '$path '
          '-> success '
          '| ${stopwatch.elapsedMilliseconds}ms',
        );
      }
    } on Object catch (e, s) {
      if (logError) {
        logger.w(
          '🌍 '
          '$path '
          '-> ${switch (e) {
            GrpcError(:final code) => code,
            _ => 'error',
          }} '
          '| ${stopwatch.elapsedMilliseconds}ms',
          stackTrace: s,
        );
      }
      rethrow;
    } finally {
      stopwatch.stop();
    }
  };
}
