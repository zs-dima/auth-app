import 'dart:async';

import 'package:auth_app/app/initialization/initialization_steps.dart';
import 'package:auth_app/app/initialization/model/dependencies.dart';
import 'package:auth_app/app/initialization/model/initialization_hook.dart';
import 'package:auth_app/app/log/logger.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier, FlutterError, PlatformDispatcher, ValueListenable;
import 'package:flutter/services.dart' show SystemChrome, DeviceOrientation;
import 'package:flutter/widgets.dart' show WidgetsBinding, WidgetsFlutterBinding;
import 'package:flutter_native_splash/flutter_native_splash.dart';

typedef InitializationProgressTuple = ({int progress, String message});

abstract interface class InitializationProgressListenable implements ValueListenable<InitializationProgressTuple> {}

class InitializationExecutor with ChangeNotifier, InitializationSteps implements InitializationProgressListenable {
  /// Ephemerally initializes the app and prepares it for use.
  Future<Dependencies>? _$currentInitialization;

  InitializationProgressTuple _value = (progress: 0, message: '');

  @override
  InitializationProgressTuple get value => _value;
  InitializationExecutor();

  /// Initializes the app and prepares it for use.
  Future<Dependencies> call({
    bool deferFirstFrame = false,
    List<DeviceOrientation>? orientations,
    required InitializationHook hook,
  }) =>
      _$currentInitialization ??= Future<Dependencies>(() async {
        late final WidgetsBinding binding;

        var currentStep = 0;
        final stepsCount = initializationSteps.length;
        final dependencies = DependenciesMutable();

        final stopwatch = Stopwatch()..start();
        void notifyProgress(int step, String message, Stopwatch watch) {
          final percent = (step * 100 ~/ stepsCount).clamp(0, 100);
          _value = (progress: percent, message: message);
          // Report the step to the listeners.
          hook.onInitializing?.call(
            InitializationStepInfo(
              stepName: message,
              step: step,
              stepsCount: stepsCount,
              spent: watch.elapsedMilliseconds,
            ),
          );
          // Notify the listeners.
          notifyListeners();
        }

        hook.onInit?.call();
        notifyProgress(0, 'Initializing', stopwatch);
        try {
          binding = WidgetsFlutterBinding.ensureInitialized();
          if (deferFirstFrame) {
            binding.deferFirstFrame();
            FlutterNativeSplash.preserve(widgetsBinding: binding);
          }

          // Override logging
          FlutterError.onError = logger.logFlutterError;
          PlatformDispatcher.instance.onError = logger.logPlatformDispatcherError;

          if (orientations != null) {
            await SystemChrome.setPreferredOrientations(orientations);
          }

          await for (final step in Stream.fromIterable(initializationSteps.entries)) {
            currentStep++;
            final stopWatch = Stopwatch()..start();
            final stepFunction = step.value(dependencies);
            final _ = stepFunction is Future //
                ? await stepFunction
                : stepFunction;

            notifyProgress(currentStep, step.key, stopWatch..stop());
          }

          final result = InitializationResult(
            dependencies: dependencies,
            stepCount: currentStep,
            msSpent: stopwatch.elapsedMilliseconds,
          );
          hook.onInitialized?.call(result);

          return result.dependencies;
        } on Object catch (error, s) {
          hook.onError?.call(currentStep, error, s);
          Error.throwWithStackTrace(error, s);
        } finally {
          stopwatch.stop();
          binding.addPostFrameCallback((_) {
            //final context = binding.renderViewElement;            // Closes splash screen, and show the app layout.
            if (!deferFirstFrame) return;
            binding.allowFirstFrame();
            FlutterNativeSplash.remove();
          });
          _$currentInitialization = null;
        }
      });
}
