import 'package:auth_app/_core/theme/extension/theme_sizes.dart';
import 'package:auth_app/settings/settings_scope.dart';
import 'package:auth_app/settings/widget/settings_widget.dart';
import 'package:ui/ui.dart';

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
          borderRadius: const .vertical(top: .circular(8.0)),
          color: colorScheme.primary,
        ),
        child: Scaffold(
          body: Padding(
            padding: theme.paddings.tiny,
            child: AppText.bodyLarge(
              'Theme settings',
              color: colorScheme.onPrimary,
              fontWeight: .bold,
              overflow: .ellipsis,
              textAlign: .center,
              maxLines: 1,
            ),
          ),
        ),
      ),
      contentPadding: EdgeInsets.zero,
      content: const SizedBox(
        width: .maxFinite,
        child: SettingsWidget(),
      ),
      // actions: <Widget>[
      //   TextButton(
      //     onPressed: () => Navigator.maybePop(context),
      //     child: const Text('Close'),
      //   ),
      // ],
      shape: const RoundedRectangleBorder(borderRadius: .all(.circular(8.0))), // TODO
      insetPadding:
          appTheme
              .size
              .isPhone //
          ? .zero
          : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
    );
  }
}
