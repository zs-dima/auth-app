import 'package:auth_app/update/controller/platform/update_check.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateCheckApiImpl', () {
    test('construction does not throw on VM', () {
      expect(UpdateCheckApiImpl.new, returnsNormally);
    });

    test('starts without a pending update', () {
      final api = UpdateCheckApiImpl();
      addTearDown(api.dispose);

      expect(api.hasPendingUpdate, isFalse);
    });

    test('updateApplication completes without error', () async {
      final api = UpdateCheckApiImpl();
      addTearDown(api.dispose);

      await expectLater(api.updateApplication(), completes);
    });

    test('dispose is idempotent', () {
      final api = UpdateCheckApiImpl()..dispose();

      expect(api.dispose, returnsNormally);
    });
  });
}
