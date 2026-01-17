import 'dart:async';

import 'package:auth_app/_core/app_tree.dart';
import 'package:auth_app/_core/log/logger.dart';
import 'package:auth_app/initialization/app_zone.dart';
import 'package:auth_app/initialization/initialization.dart';
import 'package:auth_app/initialization/widget/app_error.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:flutter/widgets.dart';
import 'package:octopus/octopus.dart';
import 'package:platform_info/platform_info.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() => appZone(() async {
  // Splash screen
  final initializationProgress = ValueNotifier<({int progress, String message})>((progress: 0, message: ''));
  /* runApp(SplashScreen(progress: initializationProgress)); */
  $initializeApp(
    onProgress: (progress, message) => initializationProgress.value = (progress: progress, message: message),
    onSuccess: (dependencies) => runApp(
      DefaultAssetBundle(
        bundle: SentryAssetBundle(),
        child: InheritedDependencies(
          dependencies: dependencies,
          child: NoAnimationScope(noAnimation: platform.js || platform.desktop, child: const AppTree()),
        ),
      ),
    ),
    onError: (error, stackTrace) {
      runApp(AppError(error: error));
      logger.e(error, stackTrace: stackTrace);
    },
  ).ignore();
});
