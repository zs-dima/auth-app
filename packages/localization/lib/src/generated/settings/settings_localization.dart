// This file is generated, do not edit it manually!
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'settings_localization_de.dart';
import 'settings_localization_en.dart';
import 'settings_localization_es.dart';
import 'settings_localization_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SettingsLocalization
/// returned by `SettingsLocalization.of(context)`.
///
/// Applications need to include `SettingsLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'settings/settings_localization.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SettingsLocalization.localizationsDelegates,
///   supportedLocales: SettingsLocalization.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the SettingsLocalization.supportedLocales
/// property.
abstract class SettingsLocalization {
  SettingsLocalization(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SettingsLocalization of(BuildContext context) {
    return Localizations.of<SettingsLocalization>(context, SettingsLocalization)!;
  }

  static const LocalizationsDelegate<SettingsLocalization> delegate = _SettingsLocalizationDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de'), Locale('en'), Locale('es'), Locale('ru')];

  /// No description provided for @customColors.
  ///
  /// In en, this message translates to:
  /// **'Custom Colors'**
  String get customColors;

  /// No description provided for @defaultThemes.
  ///
  /// In en, this message translates to:
  /// **'Default Themes'**
  String get defaultThemes;

  /// No description provided for @locales.
  ///
  /// In en, this message translates to:
  /// **'Locales'**
  String get locales;

  /// No description provided for @localeTag.
  ///
  /// In en, this message translates to:
  /// **'en_US'**
  String get localeTag;

  /// No description provided for @localeCode.
  ///
  /// In en, this message translates to:
  /// **'en'**
  String get localeCode;

  /// No description provided for @lang.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get lang;

  /// Language name in English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @languageSelection.
  ///
  /// In en, this message translates to:
  /// **'Language selection'**
  String get languageSelection;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;
}

class _SettingsLocalizationDelegate extends LocalizationsDelegate<SettingsLocalization> {
  const _SettingsLocalizationDelegate();

  @override
  Future<SettingsLocalization> load(Locale locale) {
    return SynchronousFuture<SettingsLocalization>(lookupSettingsLocalization(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_SettingsLocalizationDelegate old) => false;
}

SettingsLocalization lookupSettingsLocalization(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return SettingsLocalizationDe();
    case 'en':
      return SettingsLocalizationEn();
    case 'es':
      return SettingsLocalizationEs();
    case 'ru':
      return SettingsLocalizationRu();
  }

  throw FlutterError(
    'SettingsLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
