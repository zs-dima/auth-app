import 'dart:async';

import 'package:auth_app/app/app_tree.dart';
import 'package:auth_app/app/initialization/model/dependencies.dart';
import 'package:auth_app/app/initialization/model/initialization_hook.dart';
import 'package:auth_app/app/initialization/widget/dependencies_scope.dart';
import 'package:auth_app/app/initialization/widget/initialization.dart';
import 'package:auth_app/app/initialization/widget/initialization_splash_screen.dart';
import 'package:auth_app/app/log/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  final hook = InitializationHook.setup(
    onInitializing: _onInitializing,
    onInitialized: _onInitialized,
    onError: _onError,
    onInit: _onInit,
  );

  logger.runLogging(
    () => runZonedGuarded<void>(
      () async {
        final initialization = InitializationExecutor();

        runApp(
          DefaultAssetBundle(
            bundle: SentryAssetBundle(),
            child: DependenciesScope(
              initialization: initialization(hook: hook),
              splashScreen: InitializationSplashScreen(
                progress: initialization,
              ),
              child: const AppTree(),
            ),
          ),
        );
      },
      logger.logZoneError,
    ),
    const LogOptions(
      logInRelease: true,
      printColors: kDebugMode,
    ),
  );
}

void _onInitializing(InitializationStepInfo info) {
  final percent = (info.step * 100 ~/ info.stepsCount).clamp(0, 100);

  logger.v6(
    'Init ${info.stepName} in ${info.spent} ms | '
    'Progress: $percent%',
  );
}

void _onInitialized(InitializationResult result) {
  logger.v5('Initialization completed successfully in ${result.msSpent} ms');
}

void _onError(int step, Object error, StackTrace stackTrace) {
  logger.e('Initialization failed on step $step with error: $error, $stackTrace', stackTrace: stackTrace);
}

void _onInit() {
  logger.v5('Initialization started');
}
