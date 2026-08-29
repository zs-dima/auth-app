// This file is generated, do not edit it manually!

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'errors_localization.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class ErrorsLocalizationEs extends ErrorsLocalization {
  ErrorsLocalizationEs([String locale = 'es']) : super(locale);

  @override
  String get errInvalidFormat => 'Formato no válido';

  @override
  String get errTimeOutExceeded => 'Tiempo de espera excedido';

  @override
  String get errNotImplementedYet => 'Aún no implementado';

  @override
  String get errUnsupportedOperation => 'Operación no admitida';

  @override
  String get errFileSystemException => 'Error del sistema de archivos';

  @override
  String get errAssertionError => 'Error de aserción';

  @override
  String get errAnErrorHasOccurred => 'Ha ocurrido un error';

  @override
  String get errAnExceptionHasOccurred => 'Se ha producido una excepción';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get error => 'Error';

  @override
  String get exception => 'Excepción';

  @override
  String get anErrorHasOccurred => 'Ha ocurrido un error';

  @override
  String get anExceptionHasOccurred => 'Se ha producido una excepción';

  @override
  String get tryAgainLater => 'Por favor, inténtelo de nuevo más tarde.';

  @override
  String get invalidFormat => 'Formato no válido';

  @override
  String get timeOutExceeded => 'Tiempo de espera agotado';

  @override
  String get invalidCredentials => 'Credenciales no válidas';

  @override
  String get unimplemented => 'No implementado';

  @override
  String get notImplementedYet => 'Aún no implementado';

  @override
  String get unsupportedOperation => 'Operación no admitida';

  @override
  String get fileSystemException => 'Error del sistema de archivos';

  @override
  String get assertionError => 'Error de aserción';

  @override
  String get badStateError => 'Error de estado no válido';

  @override
  String get badRequest => 'Solicitud no válida';

  @override
  String get unauthorized => 'No autorizado';

  @override
  String get forbidden => 'Prohibido';

  @override
  String get notFound => 'No encontrado';

  @override
  String get notAcceptable => 'Inaceptable';

  @override
  String get requestTimeout => 'Tiempo de espera de la solicitud';

  @override
  String get tooManyRequests => 'Demasiadas solicitudes';

  @override
  String get internalServerError => 'Error interno del servidor';

  @override
  String get badGateway => 'Puerta de enlace incorrecta';

  @override
  String get serviceUnavailable => 'Servicio no disponible';

  @override
  String get gatewayTimeout => 'Tiempo de espera de la puerta de enlace';

  @override
  String get unknownServerError => 'Error de servidor desconocido';

  @override
  String get anUnknownErrorWasReceivedFromTheServer => 'Se recibió un error desconocido del servidor';

  @override
  String rpcErrorMessages(String code) {
    String _temp0 = intl.Intl.selectLogic(
      code,
      {
        'unavailable': 'Servidor no disponible. Contacta con soporte',
        'deadlineExceeded': 'Error del servidor. Contacta con soporte',
        'permissionDenied': 'Permiso denegado',
        'aborted': 'Solicitud de red abortada',
        'dataLoss': 'Pérdida de datos de red',
        'canceled': 'Solicitud de red cancelada',
        'failedPrecondition': 'La solicitud de red no cumple la condición previa',
        'cors': 'Error de CORS',
        'other': 'Error de red',
      },
    );
    return '$_temp0';
  }
}
