import 'package:auth_app/app/initialization/model/dependencies.dart';

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
  /// {@macro initialization_hook}
  InitializationHook({
    this.onInit,
    this.onInitializing,
    this.onInitialized,
    this.onError,
  });

  /// Setup the initialization hook.
  factory InitializationHook.setup({
    void Function()? onInit,
    void Function(InitializationStepInfo info)? onInitializing,
    void Function(InitializationResult)? onInitialized,
    void Function(int, Object error, StackTrace stackTrace)? onError,
  }) = _Hook;

  /// Called before the initialization process starts.
  void Function()? onInit;

  /// Called when the initialization process is in progress.
  void Function(InitializationStepInfo info)? onInitializing;

  /// Called when the initialization process is finished.
  void Function(InitializationResult)? onInitialized;

  /// Called when the initialization process is failed.
  void Function(int, Object error, StackTrace stackTrace)? onError;
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
  /// {@macro initialization_step_info}
  const InitializationStepInfo({
    required this.stepName,
    required this.step,
    required this.stepsCount,
    required this.spent,
  });

  /// The number of the step.
  final int step;

  /// The name of the step.
  final String stepName;

  /// The total number of steps.
  final int stepsCount;

  /// The number of milliseconds spent on the step.
  final int spent;
}
