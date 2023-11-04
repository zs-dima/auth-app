import 'package:auth_app/app/environment/model/environment.dart';

abstract class IAppEnvironment {
  String get version;
  Environment get type;
  Uri get authService;
  Uri get appService;
  String get sentryDsn;
}

class AppEnvironment implements IAppEnvironment {
  @override
  final String version;
  @override
  final Environment type;
  @override
  final Uri authService;
  @override
  final Uri appService;
  @override
  final String sentryDsn;

  const AppEnvironment.development({
    required this.version,
    required this.authService,
    required this.appService,
    required this.sentryDsn,
  }) : type = Environment.development;

  const AppEnvironment.staging({
    required this.version,
    required this.authService,
    required this.appService,
    required this.sentryDsn,
  }) : type = Environment.staging;

  const AppEnvironment.production({
    required this.version,
    required this.authService,
    required this.appService,
    required this.sentryDsn,
  }) : type = Environment.production;

  const AppEnvironment(
    this.version,
    this.type, {
    required this.authService,
    required this.appService,
    required this.sentryDsn,
  });
}
