import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_app/_core/theme/model/app_theme.dart';
import 'package:auth_app/_core/widget/common_actions.dart';
import 'package:auth_app/_core/widget/form/form_placeholder.dart';
import 'package:auth_app/_core/widget/scaffold_padding.dart';
import 'package:auth_app/settings/settings_scope.dart';
import 'package:auth_app/settings/widget/language/language_selector.dart';
import 'package:auth_app/settings/widget/theme/theme_color_selector.dart';
import 'package:auth_app/settings/widget/theme/theme_selector.dart';
import 'package:ui/ui.dart';

/// {@template settings_screen}
/// SettingsScreen widget.
/// {@endtemplate}
class SettingsScreen extends StatelessWidget {
  /// {@macro profile_screen}
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = context.screenSize;
    final lightTheme = AppTheme.light(screenSize);
    final darkTheme = AppTheme.dark(screenSize);
    final systemTheme = AppTheme.system(screenSize);

    final textTitleMedium = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface,
    );
    // SliverCommonHeader(
    //             title: const Text('Settings'),
    //             pinned: true,
    //           ),
    return Scaffold(
      appBar: AppBar(title: Text(Localization.of(context).settings), actions: CommonActions()),
      body: CustomScrollView(
        slivers: <Widget>[
          ///
          SliverPadding(
            padding: ScaffoldPadding.of(context).copyWith(top: 16, bottom: 16),
            sliver: SliverList.list(
              children: <Widget>[
                const SizedBox(width: 16),
                Column(
                  children: [
                    const Text('Text scale'),
                    Slider(
                      divisions: 8,
                      min: 0.5,
                      max: 2,
                      value: SettingsScope.textScaleOf(context).textScale,
                      onChanged: (value) {
                        SettingsScope.textScaleOf(context).setTextScale(value);
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(Localization.of(context).locales, style: textTitleMedium),
                ),
                LanguagesSelector(Localization.supportedLocales),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(Localization.of(context).default_themes, style: textTitleMedium),
                ),
                const ThemeColorSelector(Colors.primaries),
                ThemeSelector([lightTheme, darkTheme, systemTheme]),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Text(Localization.of(context).custom_colors, style: textTitleMedium),
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

                ///
                /* SizedBox(
                    height: 68,
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.settings)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      isThreeLine: false,
                      title: const Text(
                        'Settings',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1,
                        ),
                      ),
                      subtitle: const Text(
                        'Change your settings',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 1,
                        ),
                      ),
                      onTap: () => context.octopus.push(Routes.settingsDialog),
                    ),
                  ),
                  const SizedBox(height: 24), */
                const FormPlaceholder(title: false),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
