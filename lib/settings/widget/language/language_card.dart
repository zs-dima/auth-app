import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_app/settings/settings_scope.dart';
import 'package:ui/ui.dart';

class LanguageCard extends StatelessWidget {
  const LanguageCard(this._language, {super.key});

  final Locale _language;

  @override
  Widget build(BuildContext context) => Card(
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const .all(.circular(4.0)),
      ),
      child: InkWell(
        onTap: () => SettingsScope.localeOf(context).setLocale(_language),
        borderRadius: const .all(.circular(4.0)),
        child: SizedBox(
          width: 64.0,
          child: Center(
            child: AppText.bodyMedium(
              Localization.getLanguageByCode(_language.languageCode)?.nativeName ?? _language.languageCode,
              color: Theme.of(context).colorScheme.onPrimary,
              maxLines: 1,
              overflow: .ellipsis,
            ),
          ),
        ),
      ),
    ),
  );
}
