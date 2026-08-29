// This file is generated, do not edit it manually!

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'errors_localization.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class ErrorsLocalizationRu extends ErrorsLocalization {
  ErrorsLocalizationRu([String locale = 'ru']) : super(locale);

  @override
  String get errInvalidFormat => 'Неверный формат';

  @override
  String get errTimeOutExceeded => 'Таймаут превышен';

  @override
  String get errNotImplementedYet => 'Ещё не реализовано';

  @override
  String get errUnsupportedOperation => 'Неподдерживаемая операция';

  @override
  String get errFileSystemException => 'Ошибка файловой системы';

  @override
  String get errAssertionError => 'Ошибка утверждения';

  @override
  String get errAnErrorHasOccurred => 'Произошла ошибка';

  @override
  String get errAnExceptionHasOccurred => 'Произошло исключение';

  @override
  String get somethingWentWrong => 'Что-то пошло не так';

  @override
  String get error => 'Ошибка';

  @override
  String get exception => 'Исключение';

  @override
  String get anErrorHasOccurred => 'Произошла ошибка';

  @override
  String get anExceptionHasOccurred => 'Произошло исключение';

  @override
  String get tryAgainLater => 'Пожалуйста, попробуйте позже.';

  @override
  String get invalidFormat => 'Неверный формат';

  @override
  String get timeOutExceeded => 'Время ожидания истекло';

  @override
  String get invalidCredentials => 'Неверные учетные данные';

  @override
  String get unimplemented => 'Не реализовано';

  @override
  String get notImplementedYet => 'Пока не реализовано';

  @override
  String get unsupportedOperation => 'Неподдерживаемая операция';

  @override
  String get fileSystemException => 'Ошибка файловой системы';

  @override
  String get assertionError => 'Ошибка утверждения';

  @override
  String get badStateError => 'Ошибка недопустимого состояния';

  @override
  String get badRequest => 'Некорректный запрос';

  @override
  String get unauthorized => 'Не авторизовано';

  @override
  String get forbidden => 'Запрещено';

  @override
  String get notFound => 'Не найдено';

  @override
  String get notAcceptable => 'Неприемлемо';

  @override
  String get requestTimeout => 'Тайм-аут запроса';

  @override
  String get tooManyRequests => 'Слишком много запросов';

  @override
  String get internalServerError => 'Внутренняя ошибка сервера';

  @override
  String get badGateway => 'Плохой шлюз';

  @override
  String get serviceUnavailable => 'Сервис недоступен';

  @override
  String get gatewayTimeout => 'Таймаут шлюза';

  @override
  String get unknownServerError => 'Неизвестная ошибка сервера';

  @override
  String get anUnknownErrorWasReceivedFromTheServer => 'С сервера получена неизвестная ошибка';

  @override
  String rpcErrorMessages(String code) {
    String _temp0 = intl.Intl.selectLogic(
      code,
      {
        'unavailable': 'Сервер недоступен. Свяжитесь со службой поддержки',
        'deadlineExceeded': 'Ошибка сервера. Свяжитесь со службой поддержки',
        'permissionDenied': 'Доступ запрещён',
        'aborted': 'Сетевой запрос прерван',
        'dataLoss': 'Потеря сетевых данных',
        'canceled': 'Сетевой запрос отменён',
        'failedPrecondition': 'Сетевой запрос не выполнил предусловие',
        'cors': 'Ошибка CORS',
        'other': 'Сетевая ошибка',
      },
    );
    return '$_temp0';
  }
}
