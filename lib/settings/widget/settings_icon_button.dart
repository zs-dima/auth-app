import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_app/_core/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octopus/octopus.dart';

/// {@template profile_icon_button}
/// ProfileIconButton widget
/// {@endtemplate}
class SettingsIconButton extends StatelessWidget {
  /// {@macro profile_icon_button}
  const SettingsIconButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.person),
    tooltip: Localization.of(context).profileButton,
    onPressed: () {
      Octopus.maybeOf(context)?.setState(
        (state) => state
          ..removeByName(Routes.settingsDialog.name)
          ..add(Routes.settingsDialog.node()),
      );
      HapticFeedback.mediumImpact().ignore();
    },
  );
}
