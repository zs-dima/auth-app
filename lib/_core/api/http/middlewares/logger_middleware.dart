import 'dart:developer' as developer;

import 'package:auth_app/_core/api/http/api_client.dart';
import 'package:auth_app/_core/log/logger.dart';
import 'package:meta/meta.dart';

/// {@template logger_middleware}
/// Logs each request's method, path, outcome and duration. Place it early in the pipeline
/// (outermost) so it still sees changes made by later middlewares.
/// {@endtemplate}
@immutable
class LoggerMiddleware {
  /// {@macro logger_middleware}
  const LoggerMiddleware({this.logRequest = false, this.logResponse = true, this.logError = true});

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
          '🌍 '
          '[${request.method}] '
          '${request.url.path} '
          '-> success '
          '| ${stopwatch.elapsedMilliseconds}ms',
        );
      }
      return response;
    } on Object catch (e, s) {
      if (logError) {
        logger.w(
          '🌍 '
          '[${request.method}] '
          '${request.url.path} '
          '-> ${switch (e) {
            ApiClientException(:final code) => code,
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
