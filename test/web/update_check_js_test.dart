@TestOn('browser')
library;

// Browser-platform tests for the web update-check API. Run with:
//   flutter test --platform chrome test/web
// (wired into the code-analysis workflow).
//
// The test page has no sw bootstrap (`window.Bootstrap` is absent) — exactly the dev-build
// degradation path the implementation documents; these tests pin that it stays graceful.

import 'package:auth_app/update/controller/platform/update_check_js.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateCheckApiImpl without window.Bootstrap', () {
    test('constructs gracefully and reports no pending update', () {
      final api = UpdateCheckApiImpl();
      addTearDown(api.dispose);
      expect(api.hasPendingUpdate, isFalse);
    });

    test('onUpdateAvailable is a broadcast stream that closes on dispose', () async {
      final api = UpdateCheckApiImpl();
      expect(api.onUpdateAvailable.isBroadcast, isTrue);
      final done = api.onUpdateAvailable.listen((_) {}).asFuture<void>().then((_) {}, onError: (_) {});
      api.dispose();
      await done; // the subscription ends because the controller closed
    });

    test('dispose is idempotent', () {
      final api = UpdateCheckApiImpl()..dispose();
      expect(api.dispose, returnsNormally);
    });
  });
}
