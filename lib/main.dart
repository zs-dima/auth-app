import 'dart:async';

import 'package:auth_app/_core/app_tree.dart';
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
  // Named so the failure screen can re-run the whole sequence: the memoized init future
  // self-clears in its `finally`, and a failed attempt disposes its partial dependencies.
  // On retry the first frame is NOT deferred — AppError is already on screen and its
  // progress indicator must keep painting during re-initialization.
  void launch({bool deferFirstFrame = true}) => $initializeApp(
    deferFirstFrame: deferFirstFrame,
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
      runApp(
        AppError(
          error: error,
          stackTrace: stackTrace,
          // Intentional self-reference: retry re-enters the launch sequence.
          // ignore: avoid-recursive-calls
          onRetry: () => launch(deferFirstFrame: false),
        ),
      );
      // Deliberately NOT logged here: `composeDependencies` reported the failing step while the
      // journal was still attached, and this call site had the error object as its BODY — which
      // grouped every boot failure into its own crash-reporter issue.
    },
  ).ignore();
  launch();
});
