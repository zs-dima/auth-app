import 'package:auth_app/_core/api/_core/transport_log.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:http_kit/http_kit.dart';
import 'package:meta/meta.dart';

/// {@template logger_middleware}
/// Logs one canonical line per request — method, route, status and duration as attributes. Place
/// it early in the pipeline (outermost) so it still sees changes made by later middlewares, and so
/// what it times is the whole logical request including retries.
/// {@endtemplate}
@immutable
class HttpLoggerMiddleware {
  /// {@macro logger_middleware}
  const HttpLoggerMiddleware();

  /// Expected teardown — a cancelled request, which is what a sign-out does to an upload in
  /// flight. Logged at `debug`, not `warn`: refresh_token.md §13 promises that a user's own logout
  /// is not reported as a problem, and a warning is read as one — it is a breadcrumb on the next
  /// crash report and it colours the dev-menu journal red. The Connect side has had this carve-out
  /// since the transport migration; this is its HTTP twin.
  @visibleForTesting
  static bool isExpectedTeardown(Object e) => e is ApiClientException$Cancelled;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    final stopwatch = Stopwatch()..start();
    // The route, never the full URL: a query string is where identifiers and tokens live, and this
    // value is journaled and shipped as a breadcrumb. The HOST is separate because it is the half
    // that may leave the device as a Sentry tag — an S3 object key (`users/<id>/avatar.webp`) is an
    // identifier, a hostname is not (see `SentryTelemetry._taggable`).
    final route = <String, Object?>{
      'http.method': request.method,
      'http.host': request.url.host,
      'http.route': request.url.path,
    };
    try {
      // Tier 5, below the console default — see the Connect twin.
      log.v5('Http | call | started', meta: route);
      final response = await innerHandler(request, context);
      logTransportCall(
        area: 'Http',
        outcome: 'ok',
        elapsedMs: stopwatch.elapsedMilliseconds,
        meta: <String, Object?>{...route, 'http.status_code': response.statusCode},
      );
      return response;
    } on Object catch (e, s) {
      final teardown = isExpectedTeardown(e);
      logTransportCall(
        area: 'Http',
        outcome: teardown ? 'canceled' : 'failed',
        level: teardown ? .debug : .warn,
        elapsedMs: stopwatch.elapsedMilliseconds,
        meta: <String, Object?>{
          ...route,
          if (e case ApiClientException(:final statusCode)) 'http.status_code': statusCode,
          if (e case ApiClientException(:final code)) 'http.error_code': code,
        },
        // Expected teardown carries no error: an attached cause would put `exception.*` on a
        // line that describes normal shutdown.
        error: teardown ? null : e,
        stackTrace: teardown ? null : s,
      );
      rethrow;
    } finally {
      stopwatch.stop();
    }
  };
}
