import 'dart:developer' as developer;

import 'package:auth_app/_core/api/_core/transport_log.dart';
import 'package:auth_app/_core/log/logger.dart';
import 'package:http_client/http_client.dart';
import 'package:meta/meta.dart';

/// {@template logger_middleware}
/// Logs each request's method, path, outcome and duration. Place it early in the pipeline
/// (outermost) so it still sees changes made by later middlewares.
/// {@endtemplate}
@immutable
class HttpLoggerMiddleware {
  /// {@macro logger_middleware}
  const HttpLoggerMiddleware({this.logRequest = false, this.logResponse = true, this.logError = true});

  final bool logRequest;
  final bool logResponse;
  final bool logError;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    final stopwatch = Stopwatch()..start();
    try {
      if (logRequest) {
        developer.log('[${request.method}] ${request.url.path}', name: 'http', time: DateTime.now(), level: 300);
      }
      final response = await innerHandler(request, context);
      if (logResponse) {
        logger.v4(
          formatTransportLog(
            subject: '[${request.method}] ${request.url.path}',
            outcome: 'success',
            elapsedMs: stopwatch.elapsedMilliseconds,
          ),
        );
      }
      return response;
    } on Object catch (e, s) {
      if (logError) {
        logger.w(
          formatTransportLog(
            subject: '[${request.method}] ${request.url.path}',
            outcome: switch (e) {
              ApiClientException(:final code) => code,
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
