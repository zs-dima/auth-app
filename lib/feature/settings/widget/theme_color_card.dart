import 'package:auth_app/feature/settings/settings_scope.dart';
import 'package:flutter/material.dart';

class ThemeColorCard extends StatelessWidget {
  const ThemeColorCard(this._color, {super.key});

  final Color _color;

  @override
  Widget build(BuildContext context) => Card(
        child: Material(
          color: _color,
          borderRadius: const BorderRadius.all(
            Radius.circular(4),
          ),
          child: InkWell(
            onTap: () {
              SettingsScope.themeOf(context).setThemeSeedColor(_color);
            },
            borderRadius: const BorderRadius.all(
              Radius.circular(4),
            ),
            child: const SizedBox.square(dimension: 64),
          ),
        ),
      );
}
