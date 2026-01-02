import 'dart:io' as io;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

Future<void> $platformInitialization() =>
    // Compile-time check for initialization:
    io.Platform.isAndroid || io.Platform.isIOS ? _mobileInitialization() : _desktopInitialization();

Future<void> _mobileInitialization() async {
  // Android and iOS initialization

  // Set the app to be full-screen (no buttons, bar or notifications on top).
  //await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Check if size of the screen is less than 600 pixels
  // to determine if the device is a phone or a tablet.
  final view = ui.PlatformDispatcher.instance.views.firstOrNull;
  if (view != null) {
    final size = view.physicalSize / view.devicePixelRatio;
    if (size.shortestSide < 600) {
      // If the device is a phone, set the preferred orientation to portrait only.
      await SystemChrome.setPreferredOrientations([
        .portraitUp, // Portrait up orientation
        .portraitDown, // Portrait down orientation
      ]);
    } else {
      // If the device is a tablet or larger, set the any orientation.
      // This will allow the app to be used in both landscape and portrait modes.
      await SystemChrome.setPreferredOrientations([
        .portraitUp, // Portrait up orientation
        .landscapeLeft, // Landscape left orientation
        .landscapeRight, // Landscape right orientation
        .portraitDown, // Portrait down orientation
      ]);
    }
  }
}

/// Desktop initialization for macOS, Linux and Windows platforms.
Future<void> _desktopInitialization() async {
  // Must add this line.
  await windowManager.ensureInitialized();
  final windowOptions = WindowOptions(
    minimumSize: const Size(360.0, 480.0),
    size: const Size(960.0, 800.0),
    // maximumSize: const Size(1440.0, 1080.0),
    center: true,
    backgroundColor: ui.PlatformDispatcher.instance.platformBrightness == .dark
        ? ThemeData.dark().colorScheme.surface
        : ThemeData.light().colorScheme.surface,
    skipTaskbar: false,
    titleBarStyle: .hidden,
    /* alwaysOnTop: true, */
    fullScreen: false,
    title: '',
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (io.Platform.isMacOS) {
      await windowManager.setMovable(true);
    }
    await windowManager.setMaximizable(false);
    await windowManager.show();
    await windowManager.focus();
  });
}

void $updateLoadingProgress({int progress = 100, String text = ''}) {}

void $removeLoadingWidget() {}
