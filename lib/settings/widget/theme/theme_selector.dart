import 'package:auth_app/_core/theme/model/app_theme.dart';
import 'package:auth_app/settings/settings_scope.dart';
import 'package:flutter/material.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector(this._themes, {super.key});

  final List<AppTheme> _themes;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 100,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _themes.length,
      itemBuilder: (context, index) {
        final theme = _themes[index];

        return Padding(padding: const EdgeInsets.all(8), child: _ThemeCard(theme));
      },
    ),
  );
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard(this._theme);

  final AppTheme _theme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Material(
        color: _theme.seed ?? _theme.computeTheme(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: InkWell(
          onTap: () =>
              SettingsScope.themeOf(context).setTheme(AppTheme(mode: _theme.mode, seed: null, size: _theme.size)),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          child: SizedBox.square(
            dimension: 64,
            child: Center(child: Text(_theme.mode.name, style: theme.textTheme.bodyMedium)),
          ),
        ),
      ),
    );
  }
}
