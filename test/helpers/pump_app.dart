// Shared test harness, meant to be imported by tests — public members are the point.
// ignore_for_file: avoid-top-level-members-in-tests

import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_app/_core/model/dependencies.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:auth_app/settings/settings_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_dependencies.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] wrapped the way the real app wraps screens:
  /// [InheritedDependencies] above a [MaterialApp] with the app's localization delegates.
  ///
  /// [SettingsScope] is opt-in ([withSettingsScope]) — it requires `dependencies.settings`
  /// on mount, which would tax every test that doesn't exercise settings.
  Future<void> pumpApp(
    Widget widget, {
    Dependencies? dependencies,
    Locale? locale,
    bool withSettingsScope = false,
  }) async {
    await pumpWidget(
      InheritedDependencies(
        dependencies: dependencies ?? TestDependencies(),
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: Localization.localizationDelegates,
          supportedLocales: Localization.supportedLocales,
          home: withSettingsScope ? SettingsScope(child: widget) : widget,
        ),
      ),
    );
    // Flush the async localization delegate load.
    await pump();
  }
}
