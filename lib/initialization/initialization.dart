import 'dart:async';

import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_app/_core/model/dependencies.dart';
import 'package:auth_app/initialization/initialize_dependencies.dart';
import 'package:auth_app/initialization/platform/platform_initialization.dart' as platform_initialization;
import 'package:auth_app/initialization/widget/error_box.dart';
/* import 'package:database/database.dart'; */
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Ephemerally initializes the app and prepares it for use.
Future<Dependencies>? _$initializeApp;

/// Initializes the app and prepares it for use.
Future<Dependencies> $initializeApp({
  bool deferFirstFrame = true,
  List<DeviceOrientation>? orientations,
  void Function(int progress, String message)? onProgress,
  FutureOr<void> Function(Dependencies dependencies)? onSuccess,
  void Function(Object error, StackTrace stackTrace)? onError,
}) => _$initializeApp ??= Future<Dependencies>(() async {
  late final WidgetsBinding binding;
  final stopwatch = Stopwatch()..start();
  try {
    binding = WidgetsFlutterBinding.ensureInitialized();
    if (deferFirstFrame) {
      binding.deferFirstFrame();
      // FlutterNativeSplash.preserve(widgetsBinding: binding);
    }

    await platform_initialization.$platformInitialization();

    const offset = 90;
    platform_initialization.$updateLoadingProgress(
      progress: offset,
      text: 'Logic initialization started...',
    );

    FlutterError.onError = logFlutterError;
    PlatformDispatcher.instance.onError = logPlatformError;
    ErrorWidget.builder = buildAppErrorWidget;

    if (orientations != null) {
      await SystemChrome.setPreferredOrientations(orientations);
    }

    final dependenciesFuture = $initializeDependencies(
      onProgress: (percent, message) {
        // Update the loading progress with the provided values.
        final progress = (offset + percent * (100 - offset) / 100).clamp(offset, 100).round();

        platform_initialization.$updateLoadingProgress(
          progress: progress,
          text: message,
        );

        onProgress?.call(progress, message);
      },
    );
    final dependencies = await dependenciesFuture.timeout(
      const Duration(minutes: 7),
      onTimeout: () {
        // The abandoned composition keeps running in the background; if it ever completes,
        // release its resources — nobody will consume it (a retry builds a fresh one).
        dependenciesFuture.then($disposeDependencies).ignore();
        // Logged HERE, unlike a failed step: no step failed, so `composeDependencies`
        // reported nothing and this was the one boot outcome that left no trace anywhere.
        log.e('Boot | compose | timed out', meta: <String, Object?>{'app.boot.timeout_s': 420});
        throw TimeoutException('Initialization timed out after 7 minutes');
      },
    );

    final onSuccessCall = onSuccess?.call(dependencies);
    final _ = onSuccessCall is Future ? await onSuccessCall : onSuccessCall;

    // Maintenance runs AFTER the first frame and after first-build contention, not as an init
    // step: nothing about trimming last week's journal is worth making the user wait for.
    binding.addPostFrameCallback(
      (_) => Future<void>.delayed(const Duration(seconds: 3)).then((_) => $maintainDatabase(dependencies)).ignore(),
    );

    platform_initialization.$updateLoadingProgress(
      progress: 100,
      text: 'Initialization complete',
    );

    return dependencies;
  } on Object catch (error, stackTrace) {
    // Not logged here: `composeDependencies` already reported the step that failed, WITH the
    // journal sink still attached. A second line here (and a third in `main`) produced three
    // crash-reporter issues for one boot, two of them after the sink was removed.
    onError?.call(error, stackTrace);
    Error.throwWithStackTrace(error, stackTrace);
  } finally {
    stopwatch.stop();

    // Finalize initialization and allow the first frame to be drawn.
    binding.addPostFrameCallback((_) {
      if (!deferFirstFrame) return;
      binding.allowFirstFrame();
      platform_initialization.$removeLoadingWidget();
      // FlutterNativeSplash.remove();

      //final context = binding.renderViewElement;
    });
    _$initializeApp = null;
  }
});

/// Resets the app's state to its initial state.
@visibleForTesting
Future<void> $resetApp(Dependencies dependencies) async {}

/// Disposes the app and releases all resources (A6): cancels module subscriptions and tears down
/// the shared Connect HTTP client, external HTTP client, auth handler and repository owned by
/// [dependencies]. Wired to the app lifecycle (`AppLifecycleListener.onDetached` in `AppTree`).
Future<void> $disposeApp(Dependencies dependencies) async {
  await $disposeDependencies(dependencies);
  // await $resetApp(dependencies);
  // await Sentry.close();
  // await Octopus.dispose();
  // await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
}
