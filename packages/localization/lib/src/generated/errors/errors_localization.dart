// This file is generated, do not edit it manually!
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'errors_localization_de.dart';
import 'errors_localization_en.dart';
import 'errors_localization_es.dart';
import 'errors_localization_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ErrorsLocalization
/// returned by `ErrorsLocalization.of(context)`.
///
/// Applications need to include `ErrorsLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'errors/errors_localization.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ErrorsLocalization.localizationsDelegates,
///   supportedLocales: ErrorsLocalization.supportedLocales,
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
/// be consistent with the languages listed in the ErrorsLocalization.supportedLocales
/// property.
abstract class ErrorsLocalization {
  ErrorsLocalization(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ErrorsLocalization of(BuildContext context) {
    return Localizations.of<ErrorsLocalization>(context, ErrorsLocalization)!;
  }

  static const LocalizationsDelegate<ErrorsLocalization> delegate = _ErrorsLocalizationDelegate();

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

  /// No description provided for @errInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get errInvalidFormat;

  /// No description provided for @errTimeOutExceeded.
  ///
  /// In en, this message translates to:
  /// **'Time out exceeded'**
  String get errTimeOutExceeded;

  /// No description provided for @errNotImplementedYet.
  ///
  /// In en, this message translates to:
  /// **'Not implemented yet'**
  String get errNotImplementedYet;

  /// No description provided for @errUnsupportedOperation.
  ///
  /// In en, this message translates to:
  /// **'Unsupported operation'**
  String get errUnsupportedOperation;

  /// No description provided for @errFileSystemException.
  ///
  /// In en, this message translates to:
  /// **'File system error'**
  String get errFileSystemException;

  /// No description provided for @errAssertionError.
  ///
  /// In en, this message translates to:
  /// **'Assertion error'**
  String get errAssertionError;

  /// No description provided for @errAnErrorHasOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred'**
  String get errAnErrorHasOccurred;

  /// No description provided for @errAnExceptionHasOccurred.
  ///
  /// In en, this message translates to:
  /// **'An exception has occurred'**
  String get errAnExceptionHasOccurred;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @exception.
  ///
  /// In en, this message translates to:
  /// **'Exception'**
  String get exception;

  /// No description provided for @anErrorHasOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred'**
  String get anErrorHasOccurred;

  /// No description provided for @anExceptionHasOccurred.
  ///
  /// In en, this message translates to:
  /// **'An exception has occurred'**
  String get anExceptionHasOccurred;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later.'**
  String get tryAgainLater;

  /// No description provided for @invalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get invalidFormat;

  /// No description provided for @timeOutExceeded.
  ///
  /// In en, this message translates to:
  /// **'Time out exceeded'**
  String get timeOutExceeded;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// No description provided for @unimplemented.
  ///
  /// In en, this message translates to:
  /// **'Unimplemented'**
  String get unimplemented;

  /// No description provided for @notImplementedYet.
  ///
  /// In en, this message translates to:
  /// **'Not implemented yet'**
  String get notImplementedYet;

  /// No description provided for @unsupportedOperation.
  ///
  /// In en, this message translates to:
  /// **'Unsupported operation'**
  String get unsupportedOperation;

  /// No description provided for @fileSystemException.
  ///
  /// In en, this message translates to:
  /// **'File system error'**
  String get fileSystemException;

  /// No description provided for @assertionError.
  ///
  /// In en, this message translates to:
  /// **'Assertion error'**
  String get assertionError;

  /// No description provided for @badStateError.
  ///
  /// In en, this message translates to:
  /// **'Bad state error'**
  String get badStateError;

  /// No description provided for @badRequest.
  ///
  /// In en, this message translates to:
  /// **'Bad request'**
  String get badRequest;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get unauthorized;

  /// No description provided for @forbidden.
  ///
  /// In en, this message translates to:
  /// **'Forbidden'**
  String get forbidden;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @notAcceptable.
  ///
  /// In en, this message translates to:
  /// **'Not acceptable'**
  String get notAcceptable;

  /// No description provided for @requestTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timeout'**
  String get requestTimeout;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests'**
  String get tooManyRequests;

  /// No description provided for @internalServerError.
  ///
  /// In en, this message translates to:
  /// **'Internal server error'**
  String get internalServerError;

  /// No description provided for @badGateway.
  ///
  /// In en, this message translates to:
  /// **'Bad gateway'**
  String get badGateway;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable'**
  String get serviceUnavailable;

  /// No description provided for @gatewayTimeout.
  ///
  /// In en, this message translates to:
  /// **'Gateway timeout'**
  String get gatewayTimeout;

  /// No description provided for @unknownServerError.
  ///
  /// In en, this message translates to:
  /// **'Unknown server error'**
  String get unknownServerError;

  /// No description provided for @anUnknownErrorWasReceivedFromTheServer.
  ///
  /// In en, this message translates to:
  /// **'An unknown error was received from the server'**
  String get anUnknownErrorWasReceivedFromTheServer;

  /// Connect RPC error text by code (ICU select); unauthenticated/internal compose the server-provided message in Dart and are not listed here
  ///
  /// In en, this message translates to:
  /// **'{code, select, unavailable{Backend unavailable. Please contact support} deadlineExceeded{Backend error. Please contact support} permissionDenied{Permission denied} aborted{Network request aborted} dataLoss{Network data loss} canceled{Network request cancelled} failedPrecondition{Network request failed precondition} cors{CORS error} other{Network error}}'**
  String rpcErrorMessages(String code);
}

class _ErrorsLocalizationDelegate extends LocalizationsDelegate<ErrorsLocalization> {
  const _ErrorsLocalizationDelegate();

  @override
  Future<ErrorsLocalization> load(Locale locale) {
    return SynchronousFuture<ErrorsLocalization>(lookupErrorsLocalization(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_ErrorsLocalizationDelegate old) => false;
}

ErrorsLocalization lookupErrorsLocalization(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return ErrorsLocalizationDe();
    case 'en':
      return ErrorsLocalizationEn();
    case 'es':
      return ErrorsLocalizationEs();
    case 'ru':
      return ErrorsLocalizationRu();
  }

  throw FlutterError(
    'ErrorsLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
