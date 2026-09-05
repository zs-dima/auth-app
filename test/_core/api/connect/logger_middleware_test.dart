import 'package:auth_app/_core/api/connect/middlewares/logger_middleware.dart';
import 'package:auth_model/auth_model.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectLoggerMiddleware.isExpectedTeardown', () {
    // The guarantee under test (refresh_token.md §13): expected teardown — logout aborting
    // in-flight calls — must NOT produce a warning. A warning is not an issue any more (only
    // `error` is captured), but it IS a Sentry breadcrumb on the next report and it colours the
    // dev-menu journal red, so a normal sign-out would read as a fault either way.
    test('canceled RPC and ended-session are expected teardown', () {
      expect(ConnectLoggerMiddleware.isExpectedTeardown(ConnectException(.canceled, 'aborted')), isTrue);
      expect(ConnectLoggerMiddleware.isExpectedTeardown(const RequestSessionEndedException()), isTrue);
    });

    test('real failures are not', () {
      expect(ConnectLoggerMiddleware.isExpectedTeardown(ConnectException(.unavailable, 'down')), isFalse);
      expect(ConnectLoggerMiddleware.isExpectedTeardown(ConnectException(.internal, 'boom')), isFalse);
      expect(ConnectLoggerMiddleware.isExpectedTeardown(Exception('network blip')), isFalse);
      expect(ConnectLoggerMiddleware.isExpectedTeardown(const CredentialsRejectedException()), isFalse);
    });
  });
}
