import 'package:auth_app/settings/widget/language/language_card.dart';
import 'package:flutter/material.dart';

class LanguagesSelector extends StatelessWidget {
  const LanguagesSelector(this._languages, {super.key});

  final List<Locale> _languages;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 100.0,
    child: ListView.builder(
      scrollDirection: .horizontal,
      itemCount: _languages.length,
      itemBuilder: (context, index) {
        final language = _languages.elementAt(index);

        return Padding(padding: const .all(8.0), child: LanguageCard(language));
      },
    ),
  );
}
