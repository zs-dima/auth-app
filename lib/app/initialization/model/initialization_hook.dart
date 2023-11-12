import 'package:auth_app/app/initialization/model/dependencies.dart';
import 'package:flutter/foundation.dart';

typedef AppInitializingCallback = void Function(InitializationStepInfo info);
typedef AppInitializedCallback = void Function(InitializationResult result);
typedef AppInitializationErrorCallback = void Function(int step, Object error, StackTrace stackTrace);

/// {@template initialization_hook}
/// A hook for the initialization process.
///
/// The [onInit] is called before the initialization process starts.
///
/// The [onInitializing] is called when the
/// initialization process is in progress.
///
/// The [onInitialized] is called when the initialization process is finished.
///
/// The [onError] is called when the initialization process is failed.
/// {@endtemplate}
abstract interface class InitializationHook {
  /// Called before the initialization process starts.
  VoidCallback? onInit;

  /// Called when the initialization process is in progress.
  AppInitializingCallback? onInitializing;

  /// Called when the initialization process is finished.
  AppInitializedCallback? onInitialized;

  /// Called when the initialization process is failed.
  AppInitializationErrorCallback? onError;

  /// {@macro initialization_hook}
  InitializationHook({
    this.onInit,
    this.onInitializing,
    this.onInitialized,
    this.onError,
  });

  /// Setup the initialization hook.
  factory InitializationHook.setup({
    VoidCallback? onInit,
    AppInitializingCallback? onInitializing,
    AppInitializedCallback? onInitialized,
    AppInitializationErrorCallback? onError,
  }) = _Hook;
}

final class _Hook extends InitializationHook {
  _Hook({
    super.onInit,
    super.onInitializing,
    super.onInitialized,
    super.onError,
  });
}

/// {@template initialization_step_info}
/// A class which contains information about initialization step.
/// {@endtemplate}
class InitializationStepInfo {
  /// The number of the step.
  final int step;

  /// The name of the step.
  final String stepName;

  /// The total number of steps.
  final int stepsCount;

  /// The number of milliseconds spent on the step.
  final int spent;

  /// {@macro initialization_step_info}
  const InitializationStepInfo({
    required this.stepName,
    required this.step,
    required this.stepsCount,
    required this.spent,
  });
}
