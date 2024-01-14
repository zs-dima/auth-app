// ignore_for_file: prefer-static-class, prefer-typedefs-for-callbacks

import 'dart:async';

import 'package:auth_app/app/app.dart';
import 'package:auth_app/app/initialization/initialize_dependencies.dart';
import 'package:auth_app/app/log/logger.dart';
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
  void Function(Dependencies dependencies)? onSuccess,
  void Function(Object error, StackTrace stackTrace)? onError,
}) =>
    _$initializeApp ??= Future<Dependencies>(() async {
      late final WidgetsBinding binding;
      final stopwatch = Stopwatch()..start();
      try {
        binding = WidgetsFlutterBinding.ensureInitialized();
        if (deferFirstFrame) {
          binding.deferFirstFrame();
          // FlutterNativeSplash.preserve(widgetsBinding: binding);
        }

        FlutterError.onError = logger.logFlutterError;
        PlatformDispatcher.instance.onError = logger.logPlatformDispatcherError;

        if (orientations != null) {
          await SystemChrome.setPreferredOrientations(orientations);
        }

        final dependencies = await $initializeDependencies(onProgress: onProgress).timeout(const Duration(minutes: 7));
        onSuccess?.call(dependencies);

        return dependencies;
      } on Object catch (error, stackTrace) {
        onError?.call(error, stackTrace);
        logger.e('Initialization failed', error: error, stackTrace: stackTrace);
        Error.throwWithStackTrace(error, stackTrace);
      } finally {
        stopwatch.stop();
        binding.addPostFrameCallback((_) {
          // Closes splash screen, and show the app layout.
          if (deferFirstFrame) {
            binding.allowFirstFrame();
            // FlutterNativeSplash.remove();
          }
          //final context = binding.renderViewElement;
        });
        _$initializeApp = null;
      }
    });

/// Resets the app's state to its initial state.
@visibleForTesting
void $resetApp() {}

/// Disposes the app and releases all resources.
@visibleForTesting
void $disposeApp() {}
