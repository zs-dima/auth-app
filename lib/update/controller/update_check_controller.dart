// ignore_for_file: argument_type_not_assignable, avoid_web_libraries_in_flutter
import 'dart:async';

import 'package:auth_app/_core/message/controller/app_message_controller_mixin.dart';
import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_app/_core/model/app_metadata.dart';
import 'package:auth_app/update/controller/update_check_api.dart';
import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web/web.dart' as web;

part 'update_check_controller.freezed.dart';

@freezed
sealed class UpdateCheckState with _$UpdateCheckState {
  const factory UpdateCheckState.idle(String version) = _IdleState;
  const factory UpdateCheckState.updateAvailable(String version) = UpdateAvailableState;
}

final class UpdateCheckController extends StateController<UpdateCheckState>
    with SequentialControllerHandler, AppMessageControllerMixin {
  UpdateCheckController({
    required UpdateCheckApi updateCheckApi,
    required AppMetadata metadata,
    required AppMessageController messageController,
  }) : _updateCheckApi = updateCheckApi,
       super(initialState: UpdateCheckState.idle(metadata.appVersion)) {
    this.messageController = messageController;
    _startUpdateCheckStream();
  }

  final UpdateCheckApi _updateCheckApi;

  StreamSubscription<void>? _updateSubscription;

  Future<void> applyUpdate() async {
    await _updateCheckApi.updateApplication();
  }

  Future<void> checkAndApplyPendingUpdate() async {
    await _updateCheckApi.tryReloadApplication();
  }

  void ignoreUpdate() => handle(
    () async => setState(UpdateCheckState.idle(state.version)),
    error: (error, stackTrace) async => setError('Error on ignore update ${state.version}', error, stackTrace),
    name: 'ignoreUpdate',
  );

  void update() => handle(
    () async {
      setState(UpdateCheckState.idle(state.version));
      web.window.location.reload();
    },
    error: (error, stackTrace) async => setError('Error on update ${state.version}', error, stackTrace),
    name: 'update',
  );

  void checkForUpdates() => handle(
    () async {
      final newVersion = await _updateCheckApi.getNewVersion();
      final newAppVersion = newVersion.version;

      if (newAppVersion == null || newAppVersion == state.version) return;

      setState(UpdateCheckState.updateAvailable(newAppVersion));
    },
    error: (error, stackTrace) async => setError('Error on loading creatives', error, stackTrace),
    name: '_checkForUpdates',
  );

  @override
  void dispose() {
    _updateSubscription?.cancel();
    super.dispose();
  }

  void _startUpdateCheckStream() {
    // Perform an immediate check
    // checkForUpdates();

    // Create the periodic stream for ongoing checks
    _updateSubscription = Stream<void>.periodic(const Duration(minutes: 39)).listen(
      (_) => checkForUpdates(),
      cancelOnError: false,
    );
  }
}
