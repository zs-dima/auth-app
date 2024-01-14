import 'package:auth_app/app/app.dart';
import 'package:auth_app/app/theme/extension/theme_sizes.dart';
import 'package:auth_app/app/theme/model/app_theme.dart';
import 'package:auth_app/feature/settings/widget/language_selector.dart';
import 'package:auth_app/feature/settings/widget/theme_color_selector.dart';
import 'package:auth_app/feature/settings/widget/theme_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_tool/ui_tool.dart';

/// {@template sample_page}
/// SamplePage widget
/// {@endtemplate}
class SettingsWidget extends StatelessWidget {
  /// {@macro sample_page}
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = context.screenSize;
    final lightTheme = AppTheme.light(screenSize);
    final darkTheme = AppTheme.dark(screenSize);
    final systemTheme = AppTheme.system(screenSize);

    final textTitleMedium = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onBackground,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // SliverAppBar(title: Text(Localization.of(context).appTitle)),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    Localization.of(context).locales,
                    style: textTitleMedium,
                  ),
                ),
                LanguagesSelector(Localization.supportedLocales),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    Localization.of(context).default_themes,
                    style: textTitleMedium,
                  ),
                ),
                const ThemeColorSelector(Colors.primaries),
                ThemeSelector(
                  [lightTheme, darkTheme, systemTheme],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Text(
                    Localization.of(context).custom_colors,
                    style: textTitleMedium,
                  ),
                ),
                // ThemeSelector(
                //   AppTheme.values(screenSize)
                //       .asMap()
                //       .entries
                //       .where((entry) => (entry.key + 1) % 4 == 0)
                //       .map((entry) => entry.value)
                //       .toList(),
                // ),
                const ThemeColorSelector(Colors.accents),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: ThemePaddings.defaultMedium.medium,
                child: SizedBox(
                  width: 120,
                  child: OutlinedButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      HapticFeedback.mediumImpact().ignore();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
          ),
          // SliverToBoxAdapter(
          //   child: Center(
          //     child: SizedBox(
          //       height: 100,
          //       width: 100,
          //       child: Card(
          //         color: theme.colorScheme.primaryContainer,
          //         margin: const EdgeInsets.all(8),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
