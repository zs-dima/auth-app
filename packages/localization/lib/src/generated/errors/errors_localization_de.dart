// This file is generated, do not edit it manually!

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'errors_localization.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class ErrorsLocalizationDe extends ErrorsLocalization {
  ErrorsLocalizationDe([String locale = 'de']) : super(locale);

  @override
  String get errInvalidFormat => 'Ungültiges Format';

  @override
  String get errTimeOutExceeded => 'Zeitlimit überschritten';

  @override
  String get errNotImplementedYet => 'Noch nicht implementiert';

  @override
  String get errUnsupportedOperation => 'Nicht unterstützte Operation';

  @override
  String get errFileSystemException => 'Dateisystemfehler';

  @override
  String get errAssertionError => 'Assertionsfehler';

  @override
  String get errAnErrorHasOccurred => 'Es ist ein Fehler aufgetreten';

  @override
  String get errAnExceptionHasOccurred => 'Es ist eine Ausnahme aufgetreten';

  @override
  String get somethingWentWrong => 'Etwas ist schiefgelaufen';

  @override
  String get error => 'Fehler';

  @override
  String get exception => 'Ausnahme';

  @override
  String get anErrorHasOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get anExceptionHasOccurred => 'Eine Ausnahme ist aufgetreten';

  @override
  String get tryAgainLater => 'Bitte versuchen Sie es später erneut.';

  @override
  String get invalidFormat => 'Ungültiges Format';

  @override
  String get timeOutExceeded => 'Zeitüberschreitung';

  @override
  String get invalidCredentials => 'Ungültige Anmeldedaten';

  @override
  String get unimplemented => 'Nicht implementiert';

  @override
  String get notImplementedYet => 'Noch nicht implementiert';

  @override
  String get unsupportedOperation => 'Nicht unterstützte Operation';

  @override
  String get fileSystemException => 'Fehler im Dateisystem';

  @override
  String get assertionError => 'Assertionsfehler';

  @override
  String get badStateError => 'Fehler bei ungültigem Zustand';

  @override
  String get badRequest => 'Fehlerhafte Anfrage';

  @override
  String get unauthorized => 'Nicht autorisiert';

  @override
  String get forbidden => 'Verboten';

  @override
  String get notFound => 'Nicht gefunden';

  @override
  String get notAcceptable => 'Nicht akzeptabel';

  @override
  String get requestTimeout => 'Zeitüberschreitung der Anfrage';

  @override
  String get tooManyRequests => 'Zu viele Anfragen';

  @override
  String get internalServerError => 'Interner Serverfehler';

  @override
  String get badGateway => 'Fehlerhaftes Gateway';

  @override
  String get serviceUnavailable => 'Dienst nicht verfügbar';

  @override
  String get gatewayTimeout => 'Gateway-Zeitüberschreitung';

  @override
  String get unknownServerError => 'Unbekannter Serverfehler';

  @override
  String get anUnknownErrorWasReceivedFromTheServer => 'Vom Server wurde ein unbekannter Fehler empfangen';

  @override
  String rpcErrorMessages(String code) {
    String _temp0 = intl.Intl.selectLogic(
      code,
      {
        'unavailable': 'Backend nicht erreichbar. Bitte kontaktieren Sie den Support',
        'deadlineExceeded': 'Backend-Fehler. Bitte kontaktieren Sie den Support',
        'permissionDenied': 'Zugriff verweigert',
        'aborted': 'Netzwerkanfrage abgebrochen',
        'dataLoss': 'Netzwerkdatenverlust',
        'canceled': 'Netzwerkanfrage abgebrochen',
        'failedPrecondition': 'Vorbedingung der Netzwerkanfrage nicht erfüllt',
        'cors': 'CORS-Fehler',
        'other': 'Netzwerkfehler',
      },
    );
    return '$_temp0';
  }
}
