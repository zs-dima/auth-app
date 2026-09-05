import 'package:auth_app/_core/api/_core/transport_log.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_model/auth_model.dart';
import 'package:connect_kit/connect_kit.dart';
import 'package:connectrpc/connect.dart';
import 'package:meta/meta.dart';

/// {@template connect_logger_middleware}
/// Logs one canonical line per call — path, outcome and duration as attributes. Place it early in
/// the pipeline (outermost) so it still sees changes made by later interceptors, and so what it
/// times is the whole logical call including retries.
/// {@endtemplate}
@immutable
class ConnectLoggerMiddleware extends ConnectMiddleware {
  /// {@macro connect_logger_middleware}
  const ConnectLoggerMiddleware();

  /// Expected teardown — a cancelled RPC (logout aborts in-flight calls) or a request whose
  /// session has already ended (A27). Logged at `debug`, not `warn`: refresh_token.md §13 promises
  /// that a user's own logout is not reported as a problem, and a warning is read as one — it is
  /// a breadcrumb on the next crash report and it colours the dev-menu journal red.
  @visibleForTesting
  static bool isExpectedTeardown(Object e) =>
      (e is ConnectException && e.code == .canceled) || e is RequestSessionEndedException;

  @override
  ConnectMiddlewareHandler handle(ConnectMiddlewareHandler invoker) => (path, metadata) async {
    final stopwatch = Stopwatch()..start();
    try {
      // Tier 5, below the console default: "started with no line after it" is what a hang
      // looks like, and it is worth exactly one turn of the noise dial to see it.
      log.v5('Rpc | call | started', meta: <String, Object?>{'rpc.path': path});
      await invoker(path, metadata);
      logTransportCall(
        area: 'Rpc',
        outcome: 'ok',
        elapsedMs: stopwatch.elapsedMilliseconds,
        meta: <String, Object?>{'rpc.path': path, 'rpc.code': 'ok'},
      );
    } on Object catch (e, s) {
      final teardown = isExpectedTeardown(e);
      logTransportCall(
        area: 'Rpc',
        outcome: teardown ? 'canceled' : 'failed',
        level: teardown ? .debug : .warn,
        elapsedMs: stopwatch.elapsedMilliseconds,
        meta: <String, Object?>{'rpc.path': path, 'rpc.code': _code(e)},
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

  /// The RPC status of a failure, as an attribute value.
  static String _code(Object error) => switch (error) {
    // Code name (e.g. `unavailable`) — the grpc-era logger printed the raw status int.
    ConnectException(:final code) => code.name,
    RequestSessionEndedException _ => 'session_ended',
    _ => 'unknown',
  };
}
