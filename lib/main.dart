import 'dart:async';

import 'package:auth_app/app/app_tree.dart';
import 'package:auth_app/app/initialization/app_zone.dart';
import 'package:auth_app/app/initialization/initialization.dart';
import 'package:auth_app/app/initialization/widget/app_error.dart';
import 'package:auth_app/app/initialization/widget/dependencies_scope.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() => appZone(
      () {
        // Splash screen
        // final initializationProgress = ValueNotifier<({int progress, String message})>((progress: 0, message: ''));
        // runApp(SplashScreen(progress: initializationProgress));
        $initializeApp(
          // onProgress: (progress, message) => initializationProgress.value = (progress: progress, message: message),
          onSuccess: (dependencies) => runApp(
            DefaultAssetBundle(
              bundle: SentryAssetBundle(),
              child: DependenciesScope(
                dependencies: dependencies,
                child: const AppTree(),
              ),
            ),
          ),
          onError: (error, stackTrace) => runApp(AppError(error: error)),
        ).ignore();
      },
    );
