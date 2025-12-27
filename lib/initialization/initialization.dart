import 'dart:async';

import 'package:auth_app/_core/app.dart';
import 'package:auth_app/_core/log/logger.dart';
import 'package:auth_app/initialization/initialize_dependencies.dart';
import 'package:auth_app/initialization/platform/platform_initialization.dart' as platform_initialization;
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

    FlutterError.onError = logger.logFlutterError;
    PlatformDispatcher.instance.onError = logger.logPlatformDispatcherError;

    if (orientations != null) {
      await SystemChrome.setPreferredOrientations(orientations);
    }

    final dependencies =
        await $initializeDependencies(
          onProgress: (percent, message) {
            // Update the loading progress with the provided values.
            final progress = (offset + percent * (100 - offset) / 100).clamp(offset, 100).round();

            platform_initialization.$updateLoadingProgress(
              progress: progress,
              text: message,
            );

            onProgress?.call(offset + progress, message);
          },
        ).timeout(
          const Duration(minutes: 7),
          onTimeout: () => throw TimeoutException('Initialization timed out after 7 minutes'),
        );

    final onSuccessCall = onSuccess?.call(dependencies);
    final _ = onSuccessCall is Future ? await onSuccessCall : onSuccessCall;

    platform_initialization.$updateLoadingProgress(
      progress: 100,
      text: 'Initialization complete',
    );

    return dependencies;
  } on Object catch (error, stackTrace) {
    onError?.call(error, stackTrace);
    logger.e('Initialization failed', error: error, stackTrace: stackTrace);
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

/// Disposes the app and releases all resources.
@visibleForTesting
Future<void> $disposeApp(Dependencies dependencies) async {
  await $disposeDependencies();
  // TODO
  // await dependencies.dispose();
  // await $resetApp(dependencies);
  // await Sentry.close();
  // await Octopus.dispose();
  // await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
}
