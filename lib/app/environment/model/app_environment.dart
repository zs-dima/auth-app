import 'package:auth_app/app/environment/model/environment.dart';

abstract class IAppEnvironment {
  String get version;
  Environment get type;
  Uri get authService;
  Uri get appService;
  String get sentryDsn;
}

class AppEnvironment implements IAppEnvironment {
  const AppEnvironment.development({
    required String version,
    required Uri authService,
    required Uri appService,
    required String sentryDsn,
  })  : _sentryDsn = sentryDsn,
        _appService = appService,
        _authService = authService,
        _version = version,
        _type = Environment.development;

  const AppEnvironment.staging({
    required String version,
    required Uri authService,
    required Uri appService,
    required String sentryDsn,
  })  : _sentryDsn = sentryDsn,
        _appService = appService,
        _authService = authService,
        _version = version,
        _type = Environment.staging;

  const AppEnvironment.production({
    required String version,
    required Uri authService,
    required Uri appService,
    required String sentryDsn,
  })  : _sentryDsn = sentryDsn,
        _appService = appService,
        _authService = authService,
        _version = version,
        _type = Environment.production;

  const AppEnvironment(
    this._version,
    this._type, {
    required Uri authService,
    required Uri appService,
    required String sentryDsn,
  })  : _sentryDsn = sentryDsn,
        _appService = appService,
        _authService = authService;

  final String _version;
  final Environment _type;
  final Uri _authService;
  final Uri _appService;
  final String _sentryDsn;

  @override
  String get version => _version;
  @override
  Environment get type => _type;
  @override
  Uri get authService => _authService;
  @override
  Uri get appService => _appService;
  @override
  String get sentryDsn => _sentryDsn;

  @override
  String toString() => 'AppEnvironment('
      'version: $_version, '
      'type: $_type, '
      'authService: $_authService, '
      'appService: $_appService, '
      'sentryDsn: $_sentryDsn'
      ')';
}
