import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_app/_core/theme/extension/theme_sizes.dart';
import 'package:auth_app/_core/theme/model/app_theme.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:auth_app/settings/settings_scope.dart';
import 'package:auth_app/settings/widget/language/language_selector.dart';
import 'package:auth_app/settings/widget/theme/theme_color_selector.dart';
import 'package:auth_app/settings/widget/theme/theme_selector.dart';
import 'package:flutter/services.dart';
import 'package:ui/ui.dart';

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

    // final textTitleMedium = theme.textTheme.titleMedium?.copyWith(
    //   fontWeight: FontWeight.bold,
    //   color: theme.colorScheme.onSurface,
    // );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      // appBar: AppBar(title: Text(Localization.of(context).settings), actions: CommonActions()),
      body: CustomScrollView(
        slivers: [
          // SliverAppBar(title: Text(Localization.of(context).appTitle)),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              <Widget>[
                const SizedBox(height: 16.0),
                Padding(
                  padding: const .all(8.0),
                  child: AppText.titleMedium(
                    Localization.of(context).textSize,
                  ),
                ),
                Slider(
                  divisions: 8,
                  min: 0.5,
                  max: 2,
                  value: SettingsScope.textScaleOf(context).textScale,
                  onChanged: (value) {
                    SettingsScope.textScaleOf(context).setTextScale(value);
                  },
                ),
                Padding(
                  padding: const .all(8.0),
                  child: AppText.titleMedium(
                    Localization.of(context).locales,
                  ),
                ),
                LanguagesSelector(Localization.supportedLocales),
                Padding(
                  padding: const .all(8.0),
                  child: AppText.titleMedium(
                    Localization.of(context).default_themes,
                  ),
                ),
                const ThemeColorSelector(Colors.primaries),
                ThemeSelector(
                  [lightTheme, darkTheme, systemTheme],
                ),
                Padding(
                  padding: const .only(left: 8.0, top: 8.0),
                  child: AppText.titleMedium(
                    Localization.of(context).custom_colors,
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
                child: Row(
                  children: [
                    Padding(
                      padding: const .all(8.0),
                      child: AppText.titleMedium(
                        'version ${context.dependencies.metadata.appVersion}',
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact().ignore();
                        SettingsScope.of(context).resetSettings();
                      },
                      child: const AppText.titleMedium('Reset to default'),
                    ),
                    const SizedBox(width: 16.0),

                    OutlinedButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        HapticFeedback.mediumImpact().ignore();
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 16.0),
                    FilledButton(
                      // style: FilledButton.styleFrom(
                      //   shape: const RoundedRectangleBorder(borderRadius: .all(.circular(10))),
                      // ),
                      onPressed: () {
                        HapticFeedback.mediumImpact().ignore();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Save', // Localization.of(context).save,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // SliverToBoxAdapter(
          //   child: Center(
          //     child: SizedBox(
          //       height: 100.0,
          //       width: 100.0,
          //       child: Card(
          //         color: theme.colorScheme.primaryContainer,
          //         margin: const EdgeInsets.all(8.0),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
