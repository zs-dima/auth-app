// This file is generated, do not edit it manually!
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'auth_localization_de.dart';
import 'auth_localization_en.dart';
import 'auth_localization_es.dart';
import 'auth_localization_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AuthLocalization
/// returned by `AuthLocalization.of(context)`.
///
/// Applications need to include `AuthLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'auth/auth_localization.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AuthLocalization.localizationsDelegates,
///   supportedLocales: AuthLocalization.supportedLocales,
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
/// be consistent with the languages listed in the AuthLocalization.supportedLocales
/// property.
abstract class AuthLocalization {
  AuthLocalization(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AuthLocalization of(BuildContext context) {
    return Localizations.of<AuthLocalization>(context, AuthLocalization)!;
  }

  static const LocalizationsDelegate<AuthLocalization> delegate = _AuthLocalizationDelegate();

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

  /// No description provided for @logOutButton.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOutButton;

  /// No description provided for @logInButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logInButton;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @profileButton.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileButton;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @authenticate.
  ///
  /// In en, this message translates to:
  /// **'Authenticate'**
  String get authenticate;

  /// No description provided for @authenticated.
  ///
  /// In en, this message translates to:
  /// **'Authenticated'**
  String get authenticated;

  /// No description provided for @authentication.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authentication;

  /// No description provided for @logOutDescription.
  ///
  /// In en, this message translates to:
  /// **'You will be logged out from your account'**
  String get logOutDescription;

  /// No description provided for @currentUser.
  ///
  /// In en, this message translates to:
  /// **'Current user'**
  String get currentUser;
}

class _AuthLocalizationDelegate extends LocalizationsDelegate<AuthLocalization> {
  const _AuthLocalizationDelegate();

  @override
  Future<AuthLocalization> load(Locale locale) {
    return SynchronousFuture<AuthLocalization>(lookupAuthLocalization(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AuthLocalizationDelegate old) => false;
}

AuthLocalization lookupAuthLocalization(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AuthLocalizationDe();
    case 'en':
      return AuthLocalizationEn();
    case 'es':
      return AuthLocalizationEs();
    case 'ru':
      return AuthLocalizationRu();
  }

  throw FlutterError(
    'AuthLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
