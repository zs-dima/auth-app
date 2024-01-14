import 'package:auth_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octopus/octopus.dart';

/// {@template settings_button}
/// SettingsButton widget
/// {@endtemplate}
class SettingsButton extends StatelessWidget {
  /// {@macro settings_button}
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.settings),
        tooltip: Localization.of(context).settings,
        onPressed: () {
          context.octopus.push(Routes.settingsDialog);
          HapticFeedback.mediumImpact().ignore();
        },
      );
}
