import 'package:auth_app/feature/settings/settings_scope.dart';
import 'package:flutter/material.dart';

class LanguageCard extends StatelessWidget {
  const LanguageCard(this._language, {super.key});

  final Locale _language;

  @override
  Widget build(BuildContext context) => Card(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.all(
              Radius.circular(4),
            ),
          ),
          child: InkWell(
            onTap: () => SettingsScope.localeOf(context).setLocale(_language),
            borderRadius: const BorderRadius.all(
              Radius.circular(4),
            ),
            child: SizedBox(
              width: 64,
              child: Center(
                child: Text(
                  _language.languageCode,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
            ),
          ),
        ),
      );
}
