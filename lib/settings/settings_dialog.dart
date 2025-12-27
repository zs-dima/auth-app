import 'package:auth_app/_core/theme/extension/theme_sizes.dart';
import 'package:auth_app/settings/settings_scope.dart';
import 'package:auth_app/settings/settings_widget.dart';
import 'package:flutter/material.dart';

/// {@template settings_screen}
/// SettingsScreen widget.
/// {@endtemplate}
class SettingsDialog extends StatelessWidget {
  /// {@macro settings_screen}
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appTheme = SettingsScope.themeOf(context).theme;

    return AlertDialog.adaptive(
      titlePadding: EdgeInsets.zero,
      title: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          color: colorScheme.primary,
        ),
        child: Padding(
          padding: theme.paddings.tiny,
          child: Text(
            'Theme settings',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ),
      ),
      contentPadding: EdgeInsets.zero,
      content: const SizedBox(
        width: double.maxFinite,
        child: SettingsWidget(),
      ),
      // actions: <Widget>[
      //   TextButton(
      //     onPressed: () => Navigator.maybePop(context),
      //     child: const Text('Close'),
      //   ),
      // ],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))), // TODO
      insetPadding:
          appTheme
              .size
              .isPhone //
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
    );
  }
}
