import 'dart:async';

import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_app/_core/model/app_metadata.dart';
import 'package:auth_app/update/controller/update_check_api.dart';
import 'package:auth_app/update/controller/update_check_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateCheckController', () {
    test('shows update when a pending update exists', () async {
      final api = _FakeUpdateCheckApi(hasPendingUpdate: true);
      final controller = _buildController(api);
      addTearDown(controller.dispose);

      await _settleController();

      expect(controller.state, isA<UpdateAvailableState>());
    });

    test('ignoreUpdate dismisses the current pending update for the session', () async {
      final api = _FakeUpdateCheckApi(hasPendingUpdate: true);
      final controller = _buildController(api);
      addTearDown(controller.dispose);

      await _settleController();
      controller.ignoreUpdate();
      await _settleController();

      expect(controller.state, isNot(isA<UpdateAvailableState>()));

      controller.checkForUpdates();
      await _settleController();

      expect(controller.state, isNot(isA<UpdateAvailableState>()));
    });

    test('a fresh update event clears the dismissal and shows the banner again', () async {
      final api = _FakeUpdateCheckApi(hasPendingUpdate: true);
      final controller = _buildController(api);
      addTearDown(controller.dispose);

      await _settleController();
      controller.ignoreUpdate();
      await _settleController();

      api.emitUpdateAvailable();
      await _settleController();

      expect(controller.state, isA<UpdateAvailableState>());
    });

    test('update delegates activation to the api', () async {
      final api = _FakeUpdateCheckApi();
      final controller = _buildController(api);
      addTearDown(controller.dispose);

      controller.update();
      await _settleController();

      expect(api.updateApplicationCalls, 1);
    });
  });
}

UpdateCheckController _buildController(_FakeUpdateCheckApi api) => .new(
  updateCheckApi: api,
  metadata: AppMetadata(
    appName: 'Auth app',
    appVersion: '1.2.3',
    appVersionMajor: 1,
    appVersionMinor: 2,
    appVersionPatch: 3,
    appBuildTimestamp: DateTime.utc(2026, 1, 1),
    appLaunchedTimestamp: DateTime.utc(2026, 1, 1),
    deviceScreenSize: '1920x1080',
    operatingSystem: 'web',
    processorsCount: 8,
    isWeb: true,
    isRelease: true,
    locale: 'en',
    deviceVersion: 'test',
  ),
  messageController: AppMessageController(),
);

Future<void> _settleController() async {
  await Future<void>.delayed(.zero);
  await Future<void>.delayed(.zero);
}

final class _FakeUpdateCheckApi implements UpdateCheckApi {
  _FakeUpdateCheckApi({this.hasPendingUpdate = false});

  final StreamController<void> _updateAvailableController = StreamController<void>.broadcast();

  @override
  bool hasPendingUpdate;
  int updateApplicationCalls = 0;

  @override
  Stream<void> get onUpdateAvailable => _updateAvailableController.stream;

  void emitUpdateAvailable() {
    hasPendingUpdate = true;
    _updateAvailableController.add(null);
  }

  @override
  Future<void> updateApplication() async {
    updateApplicationCalls++;
  }

  @override
  void dispose() {
    unawaited(_updateAvailableController.close());
  }
}
