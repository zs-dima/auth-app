import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

FutureOr<void> $platformInitialization() => //
    io.Platform.isAndroid || io.Platform.isIOS //
        ? _mobileInitialization()
        : _desktopInitialization();

FutureOr<void> _mobileInitialization() {}

Future<void> _desktopInitialization() async {
  // Must add this line.
  await windowManager.ensureInitialized();
  final windowOptions = WindowOptions(
    minimumSize: const Size(360, 480),
    size: const Size(960, 800),
    center: true,
    backgroundColor: PlatformDispatcher.instance.platformBrightness == Brightness.dark
        ? ThemeData.dark().colorScheme.background
        : ThemeData.light().colorScheme.background,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
    fullScreen: false,
    title: 'Auth app',
  );
  await windowManager.waitUntilReadyToShow(
    windowOptions,
    () async {
      if (io.Platform.isMacOS) {
        await windowManager.setMovable(true);
      }
      await windowManager.setMaximizable(false);
      await windowManager.show();
      await windowManager.focus();
    },
  );
}
