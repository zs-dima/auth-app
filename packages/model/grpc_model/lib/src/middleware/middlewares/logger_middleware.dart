import 'dart:developer' as developer;

import 'package:grpc_model/src/middleware/grpc_middleware.dart';
import 'package:meta/meta.dart';

/// Callback for custom logging.
typedef LogCallback = void Function(String message, {Object? error, StackTrace? stackTrace});

void _defaultLog(
  String message, {
  Object? error,
  StackTrace? stackTrace,
  String name = 'grpc',
  LogCallback? customLogger,
}) {
  if (customLogger == null) {
    developer.log(
      message,
      name: name,
      time: DateTime.now(),
      level: error == null ? 800 : 900,
      error: error,
      stackTrace: stackTrace,
    );
  } else {
    customLogger(message, error: error, stackTrace: stackTrace);
  }
}

/// {@template grpc_logger_middleware}
/// Middleware for logging gRPC requests and responses.
///
/// Logs request details, response status, and timing information.
/// Should typically be added as one of the first middlewares to capture
/// the full request lifecycle.
/// {@endtemplate}
@immutable
class GrpcLoggerMiddleware extends GrpcMiddlewareBase {
  /// {@macro grpc_logger_middleware}
  const GrpcLoggerMiddleware({
    this.logRequest = false,
    this.logResponse = true,
    this.logError = true,
    this.logger,
  });

  /// Whether to log request details.
  final bool logRequest;

  /// Whether to log successful responses.
  final bool logResponse;

  /// Whether to log errors.
  final bool logError;

  /// Custom logger callback. If null, uses dart:developer log.
  final LogCallback? logger;

  @override
  GrpcHandler<Q, R> call<Q, R>(GrpcHandler<Q, R> next) => (request, context) async {
    final stopwatch = Stopwatch()..start();
    final methodPath = request.method.path;

    try {
      if (logRequest) {
        _defaultLog('🌐 [gRPC] $methodPath -> request', customLogger: logger);
      }

      final response = await next(request, context);

      if (logResponse) {
        _defaultLog(
          '🌐 [gRPC] $methodPath -> success | ${stopwatch.elapsedMilliseconds}ms',
          customLogger: logger,
        );
      }

      return response;
    } on Object catch (e, s) {
      if (logError) {
        final errorCode = switch (e) {
          GrpcClientException(:final code) => code,
          _ => 'error',
        };
        _defaultLog(
          '🌐 [gRPC] $methodPath -> $errorCode | ${stopwatch.elapsedMilliseconds}ms',
          error: e,
          stackTrace: s,
          customLogger: logger,
        );
      }
      rethrow;
    } finally {
      stopwatch.stop();
    }
  };
}

/// {@template grpc_verbose_logger_middleware}
/// Verbose logging middleware that logs detailed request/response information.
///
/// Use this for debugging purposes only, as it may log sensitive information.
/// {@endtemplate}
@immutable
class GrpcVerboseLoggerMiddleware extends GrpcMiddlewareBase {
  /// {@macro grpc_verbose_logger_middleware}
  const GrpcVerboseLoggerMiddleware({this.logger});

  /// Custom logger callback. If null, uses dart:developer log.
  final LogCallback? logger;

  @override
  GrpcHandler<Q, R> call<Q, R>(GrpcHandler<Q, R> next) => (request, context) async {
    final stopwatch = Stopwatch()..start();
    final methodPath = request.method.path;

    void log(String msg, {Object? error, StackTrace? stackTrace}) =>
        _defaultLog(msg, error: error, stackTrace: stackTrace, name: 'grpc.verbose', customLogger: logger);

    log('┌── gRPC Request ──────────────────────────────────');
    log('│ Method: $methodPath');
    log('│ Timeout: ${request.options.timeout}');
    if (request.options.metadata.isNotEmpty) {
      log('│ Metadata:');
      for (final entry in request.options.metadata.entries) {
        // Don't log sensitive headers
        final value = _isSensitiveHeader(entry.key) ? '***' : entry.value;
        log('│   ${entry.key}: $value');
      }
    }
    log('└──────────────────────────────────────────────────');

    try {
      final response = await next(request, context);

      log('┌── gRPC Response ─────────────────────────────────');
      log('│ Method: $methodPath');
      log('│ Duration: ${stopwatch.elapsedMilliseconds}ms');
      log('│ Status: success');
      if (response.headers.isNotEmpty) {
        log('│ Headers:');
        for (final entry in response.headers.entries) {
          log('│   ${entry.key}: ${entry.value}');
        }
      }
      log('└──────────────────────────────────────────────────');

      return response;
    } on GrpcClientException catch (e, s) {
      log('┌── gRPC Error ────────────────────────────────────');
      log('│ Method: $methodPath');
      log('│ Duration: ${stopwatch.elapsedMilliseconds}ms');
      log('│ Code: ${e.code}');
      log('│ Status: ${e.statusCode}');
      log('│ Message: ${e.message}');
      log('└──────────────────────────────────────────────────', error: e, stackTrace: s);
      rethrow;
    } on Object catch (e, s) {
      log('┌── gRPC Error ────────────────────────────────────');
      log('│ Method: $methodPath');
      log('│ Duration: ${stopwatch.elapsedMilliseconds}ms');
      log('│ Error: $e');
      log('└──────────────────────────────────────────────────', error: e, stackTrace: s);
      rethrow;
    } finally {
      stopwatch.stop();
    }
  };

  static bool _isSensitiveHeader(String key) {
    final lowerKey = key.toLowerCase();
    return lowerKey == 'authorization' || lowerKey.contains('token') || lowerKey.contains('secret');
  }
}
