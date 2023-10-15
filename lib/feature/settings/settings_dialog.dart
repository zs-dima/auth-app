import 'package:auth_app/app/theme/extension/theme_sizes.dart';
import 'package:auth_app/app/theme/widget/theme_scope.dart';
import 'package:auth_app/feature/settings/settings_widget.dart';
import 'package:flutter/material.dart';

void settingsDialog(BuildContext context) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        final appTheme = ThemeScope.of(context).theme;

        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))), // TODO
          insetPadding: appTheme.size.isPhone //
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
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
        );
      },
    );
