// ignore_for_file: argument_type_not_assignable
import 'dart:async';

import 'package:auth_app/_core/message/controller/app_message_controller_mixin.dart';
import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_app/_core/model/app_metadata.dart';
import 'package:auth_app/update/controller/update_check_api.dart';
import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_check_controller.freezed.dart';

@freezed
sealed class UpdateCheckState with _$UpdateCheckState {
  const factory UpdateCheckState.idle(String version) = _IdleState;
  const factory UpdateCheckState.updateAvailable(String version) = UpdateAvailableState;
  const factory UpdateCheckState.applyingUpdate(String version) = ApplyingUpdateState;
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
  bool _isCurrentPendingUpdateDismissed = false;

  void ignoreUpdate() => handle(
    () async {
      _isCurrentPendingUpdateDismissed = _updateCheckApi.hasPendingUpdate || state is UpdateAvailableState;
      setState(UpdateCheckState.idle(state.version));
    },
    error: (error, stackTrace) async => setError('Error on ignore update ${state.version}', error, stackTrace),
    name: 'ignoreUpdate',
  );

  /// Apply a pending update. Under sw 0.1.x this posts `skipWaiting` to
  /// the waiting Service Worker via `window.Bootstrap.applyUpdate(true)`,
  /// awaits the `controllerchange` handshake, and then reloads — so the
  /// new SW controls the fresh page. Falls back to a plain reload when
  /// the Bootstrap API is absent (dev) or the update path fails.
  void update() => handle(
    () async {
      if (state is ApplyingUpdateState) return;
      final version = state.version;
      setState(UpdateCheckState.applyingUpdate(version));
      try {
        await _updateCheckApi.updateApplication();
      } on Object {
        setState(UpdateCheckState.updateAvailable(version));
        rethrow;
      }
    },
    error: (error, stackTrace) async => setError('Error on update ${state.version}', error, stackTrace),
    name: 'update',
  );

  void checkForUpdates() => handle(
    () async {
      if (!_updateCheckApi.hasPendingUpdate) return;
      if (_isCurrentPendingUpdateDismissed) return;
      if (state is UpdateAvailableState || state is ApplyingUpdateState) return;
      setState(UpdateCheckState.updateAvailable(state.version));
    },
    error: (error, stackTrace) async => setError('Error on checking for updates', error, stackTrace),
    name: 'checkForUpdates',
  );

  @override
  void dispose() {
    _updateSubscription?.cancel();
    _updateCheckApi.dispose();
    super.dispose();
  }

  void _startUpdateCheckStream() {
    // Push path: the API drives a 15-min `registration.update()` poll
    // and a `visibilitychange` trigger; both resolve to a
    // `Bootstrap.onUpdateAvailable` event that lands here within ~1s,
    // so the banner appears without waiting for any periodic Dart
    // timer. Clearing `_isCurrentPendingUpdateDismissed` on each signal
    // is what lets a second deploy re-prompt after the user clicked
    // "Later" on the first one.
    _updateSubscription = _updateCheckApi.onUpdateAvailable.listen(
      (_) {
        _isCurrentPendingUpdateDismissed = false;
        checkForUpdates();
      },
      cancelOnError: false,
    );

    // Pull path bootstrap: re-check on construction in case the API
    // already saw a pending update before this controller existed
    // (e.g., sw 0.1.4's `activateWaitingAtBootstrap` left a waiting
    // worker that `Bootstrap.onUpdateAvailable` signalled during load).
    // `app_message_scope` calls `checkForUpdates()` again on its own
    // mount for the same reason.
    checkForUpdates();
  }
}
