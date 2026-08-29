import 'package:auth_app/_core/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Localization facade', () {
    test('exposes all four bucket delegates plus the global ones', () {
      final delegates = Localization.localizationDelegates;
      expect(delegates.whereType<LocalizationsDelegate<AppLocalization>>(), isNotEmpty);
      expect(delegates.whereType<LocalizationsDelegate<ErrorsLocalization>>(), isNotEmpty);
      expect(delegates.whereType<LocalizationsDelegate<SettingsLocalization>>(), isNotEmpty);
      expect(delegates.whereType<LocalizationsDelegate<AuthLocalization>>(), isNotEmpty);
      expect(delegates, hasLength(7));
    });

    test('supports exactly en, ru, es, de', () {
      expect(
        Localization.supportedLocales.map((locale) => locale.languageCode),
        unorderedEquals(['en', 'ru', 'es', 'de']),
      );
    });

    for (final locale in const [Locale('en'), Locale('ru'), Locale('es'), Locale('de')]) {
      testWidgets('no-crash matrix: every bucket resolves under $locale', (tester) async {
        late BuildContext capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: Localization.localizationDelegates,
            supportedLocales: Localization.supportedLocales,
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        await tester.pump();

        expect(() => Localization.of(capturedContext), returnsNormally);
        expect(() => ErrorsLocalization.of(capturedContext), returnsNormally);
        expect(() => SettingsLocalization.of(capturedContext), returnsNormally);
        expect(() => AuthLocalization.of(capturedContext), returnsNormally);
      });
    }

    testWidgets('factual lang row is localized; currentErrors is captured; placeholder interpolates', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: Localization.localizationDelegates,
          supportedLocales: Localization.supportedLocales,
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();

      expect(SettingsLocalization.of(capturedContext).lang, equals('Русский'));
      expect(ErrorsLocalization.of(capturedContext).error, equals('Ошибка'));
      // The context-free escape hatch used by AppMessageControllerMixin.
      expect(Localization.currentErrors, isNotNull);
      expect(Localization.currentErrors?.errInvalidFormat, equals('Неверный формат'));
      // ICU probe: meta placeholders → typed method; placeholder survives translation.
      expect(Localization.of(capturedContext).samplePlaceholder('World'), equals('Привет, World!'));
    });

    testWidgets('currentErrors follows a runtime locale switch', (tester) async {
      Widget app(Locale locale) => MaterialApp(
        locale: locale,
        localizationsDelegates: Localization.localizationDelegates,
        supportedLocales: Localization.supportedLocales,
        home: const SizedBox.shrink(),
      );

      await tester.pumpWidget(app(const Locale('en')));
      await tester.pump();
      expect(Localization.currentErrors?.error, equals('Error'));

      await tester.pumpWidget(app(const Locale('ru')));
      await tester.pump();
      expect(Localization.currentErrors?.error, equals('Ошибка'));
    });

    test('computeDefaultLocale returns a supported locale', () {
      expect(Localization.supportedLocales, contains(Localization.computeDefaultLocale));
    });
  });
}
