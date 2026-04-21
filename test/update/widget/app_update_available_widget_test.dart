import 'dart:async';

import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_app/_core/model/app_metadata.dart';
import 'package:auth_app/update/controller/update_check_api.dart';
import 'package:auth_app/update/controller/update_check_controller.dart';
import 'package:auth_app/update/widget/app_update_available_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Update Now keeps the banner visible while the update is applying', (tester) async {
    final api = _FakeUpdateCheckApi(hasPendingUpdate: true);
    final controller = _buildController(api);
    addTearDown(controller.dispose);

    await _settleController();
    await tester.pumpWidget(
      MaterialApp(
        home: _BannerHost(
          controller: controller,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(MaterialBanner), findsOneWidget);
    expect(find.text('Update Now'), findsOneWidget);

    await tester.tap(find.text('Update Now'));
    await tester.pump();

    expect(api.updateApplicationCalls, 1);
    expect(controller.state, isA<ApplyingUpdateState>());
    expect(find.byType(MaterialBanner), findsOneWidget);
    expect(find.text('Updating...'), findsOneWidget);
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
  final Completer<void> _pendingUpdateCompleter = Completer<void>();

  @override
  bool hasPendingUpdate;
  int updateApplicationCalls = 0;

  @override
  Stream<void> get onUpdateAvailable => _updateAvailableController.stream;

  @override
  Future<void> updateApplication() {
    updateApplicationCalls++;
    return _pendingUpdateCompleter.future;
  }

  @override
  void dispose() {
    if (!_pendingUpdateCompleter.isCompleted) {
      _pendingUpdateCompleter.complete();
    }
    unawaited(_updateAvailableController.close());
  }
}

class _BannerHost extends StatefulWidget {
  const _BannerHost({required this.controller});

  final UpdateCheckController controller;

  @override
  State<_BannerHost> createState() => _BannerHostState();
}

class _BannerHostState extends State<_BannerHost> {
  bool _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shown) return;
    _shown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showMaterialBanner(
        AppUpdateAvailableWidget(context, updateCheckController: widget.controller),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.expand());
}
