// This file is generated, do not edit it manually!

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'errors_localization.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ErrorsLocalizationEn extends ErrorsLocalization {
  ErrorsLocalizationEn([String locale = 'en']) : super(locale);

  @override
  String get errInvalidFormat => 'Invalid format';

  @override
  String get errTimeOutExceeded => 'Time out exceeded';

  @override
  String get errNotImplementedYet => 'Not implemented yet';

  @override
  String get errUnsupportedOperation => 'Unsupported operation';

  @override
  String get errFileSystemException => 'File system error';

  @override
  String get errAssertionError => 'Assertion error';

  @override
  String get errAnErrorHasOccurred => 'An error has occurred';

  @override
  String get errAnExceptionHasOccurred => 'An exception has occurred';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get error => 'Error';

  @override
  String get exception => 'Exception';

  @override
  String get anErrorHasOccurred => 'An error has occurred';

  @override
  String get anExceptionHasOccurred => 'An exception has occurred';

  @override
  String get tryAgainLater => 'Please try again later.';

  @override
  String get invalidFormat => 'Invalid format';

  @override
  String get timeOutExceeded => 'Time out exceeded';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String get unimplemented => 'Unimplemented';

  @override
  String get notImplementedYet => 'Not implemented yet';

  @override
  String get unsupportedOperation => 'Unsupported operation';

  @override
  String get fileSystemException => 'File system error';

  @override
  String get assertionError => 'Assertion error';

  @override
  String get badStateError => 'Bad state error';

  @override
  String get badRequest => 'Bad request';

  @override
  String get unauthorized => 'Unauthorized';

  @override
  String get forbidden => 'Forbidden';

  @override
  String get notFound => 'Not found';

  @override
  String get notAcceptable => 'Not acceptable';

  @override
  String get requestTimeout => 'Request timeout';

  @override
  String get tooManyRequests => 'Too many requests';

  @override
  String get internalServerError => 'Internal server error';

  @override
  String get badGateway => 'Bad gateway';

  @override
  String get serviceUnavailable => 'Service unavailable';

  @override
  String get gatewayTimeout => 'Gateway timeout';

  @override
  String get unknownServerError => 'Unknown server error';

  @override
  String get anUnknownErrorWasReceivedFromTheServer => 'An unknown error was received from the server';

  @override
  String rpcErrorMessages(String code) {
    String _temp0 = intl.Intl.selectLogic(
      code,
      {
        'unavailable': 'Backend unavailable. Please contact support',
        'deadlineExceeded': 'Backend error. Please contact support',
        'permissionDenied': 'Permission denied',
        'aborted': 'Network request aborted',
        'dataLoss': 'Network data loss',
        'canceled': 'Network request cancelled',
        'failedPrecondition': 'Network request failed precondition',
        'cors': 'CORS error',
        'other': 'Network error',
      },
    );
    return '$_temp0';
  }
}
