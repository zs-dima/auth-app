import 'dart:developer' as developer;

import 'package:auth_app/_core/api/http/api_client.dart';
import 'package:auth_app/_core/log/logger.dart';
import 'package:meta/meta.dart';

/// {@template logger_middleware}
/// [LoggerMiddleware] is used to print logs during network requests.
/// It should be one of the first interceptors added to the [ApiClient],
/// otherwise modifications by following interceptors will not be logged.
/// This is because the execution of interceptors is in the order of addition.
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
