import 'package:auth_app/app/locale/widget/locale_scope.dart';
import 'package:flutter/material.dart';

class LanguagesSelector extends StatelessWidget {
  const LanguagesSelector(this._languages, {super.key});

  final List<Locale> _languages;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _languages.length,
          itemBuilder: (context, index) {
            final language = _languages[index];

            return Padding(
              padding: const EdgeInsets.all(8),
              child: _LanguageCard(language),
            );
          },
        ),
      );
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard(this._language);

  final Locale _language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: InkWell(
          onTap: () => LocaleScope.of(context).setLocale(_language),
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 64,
            child: Center(
              child: Text(
                _language.languageCode,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
