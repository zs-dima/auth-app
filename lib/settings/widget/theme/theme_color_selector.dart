import 'package:auth_app/settings/widget/theme/theme_color_card.dart';
import 'package:flutter/material.dart';

class ThemeColorSelector extends StatelessWidget {
  const ThemeColorSelector(this._colors, {super.key});

  final List<Color> _colors;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 100.0,
    child: ListView.builder(
      scrollDirection: .horizontal,
      itemCount: _colors.length,
      itemBuilder: (context, index) {
        final color = _colors.elementAt(index);

        return Padding(padding: const .all(8.0), child: ThemeColorCard(color));
      },
    ),
  );
}
