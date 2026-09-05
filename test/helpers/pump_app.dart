// Shared test harness, meant to be imported by tests — public members are the point.
// ignore_for_file: avoid-top-level-members-in-tests

import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_app/_core/model/dependencies.dart';
import 'package:auth_app/_core/theme/model/app_theme.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:auth_app/settings/settings_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart' show ScreenSize, WindowSizeScope;

import 'test_dependencies.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] wrapped the way the real app wraps screens:
  /// [InheritedDependencies] above a [MaterialApp] carrying the app's THEME, localization
  /// delegates and the window-size layer.
  ///
  /// The theme is not decoration here. Until 2026-09-02 this harness pumped a bare [MaterialApp],
  /// so every app-side widget test ran against stock Material blue while the app itself rendered
  /// something else — a test could pass on a colour or a text size the user would never see.
  /// (Ported from the BreakerSonar harness.)
  ///
  /// [SettingsScope] is opt-in ([withSettingsScope]) — it requires `dependencies.settings`
  /// on mount, which would tax every test that doesn't exercise settings.
  Future<void> pumpApp(
    Widget widget, {
    Dependencies? dependencies,
    Locale? locale,
    bool withSettingsScope = false,
    ThemeMode themeMode = .dark,
    Size surfaceSize = const Size(360, 800),
  }) async {
    // A phone, not flutter_test's 800x600 desktop default. No user has an 800x600 window; a
    // screen that only fits at that size fits nowhere real.
    //
    // Sized through the VIEW, not `setSurfaceSize`. That method only changes the constraints the
    // RenderView lays out against — it leaves `view.physicalSize` alone, and `MediaQuery.fromView`
    // reads exactly that. So a test using it lays out at 360 while `MediaQuery.sizeOf` still says
    // 800x600, and anything classifying the window — `WindowSizeScope`, and therefore the whole
    // adaptive layer — silently reads a desktop class on a phone. The SDK says as much on
    // `setSurfaceSize`: "consider setting TestFlutterView.physicalSize, which works for any view".
    view
      ..devicePixelRatio = 1.0
      ..physicalSize = surfaceSize;
    addTearDown(view.reset);

    final theme = AppTheme(mode: themeMode, size: ScreenSize.phone);
    await pumpWidget(
      InheritedDependencies(
        dependencies: dependencies ?? TestDependencies(),
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: Localization.localizationDelegates,
          supportedLocales: Localization.supportedLocales,
          theme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: themeMode,
          themeAnimationDuration: .zero,
          builder: (context, child) => WindowSizeScope(child: child ?? const SizedBox.shrink()),
          home: withSettingsScope ? SettingsScope(child: widget) : widget,
        ),
      ),
    );
    // Flush the async localization delegate load.
    await pump();
  }
}
