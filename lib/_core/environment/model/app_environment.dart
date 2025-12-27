import 'package:auth_app/_core/environment/model/environment.dart';

abstract class IAppEnvironment {
  String get version;
  EnvironmentFlavor get type;
  Uri get authService;
  Uri get appService;
  Uri get whisperService;
  String get sentryDsn;
  String get aiKey;
  bool get dropDatabase;
  String get databaseName;
  bool get inMemoryDatabase;
}

class AppEnvironment implements IAppEnvironment {
  const AppEnvironment(
    this.version,
    this.type, {
    required this.authService,
    required this.appService,
    required this.whisperService,
    required this.sentryDsn,
    required this.aiKey,
    required this.dropDatabase,
    required this.databaseName,
    required this.inMemoryDatabase,
  });

  const AppEnvironment.development({
    required this.version,
    required this.authService,
    required this.appService,
    required this.whisperService,
    required this.sentryDsn,
    required this.aiKey,
    required this.dropDatabase,
    required this.databaseName,
    required this.inMemoryDatabase,
  }) : type = EnvironmentFlavor.development;

  const AppEnvironment.staging({
    required this.version,
    required this.authService,
    required this.appService,
    required this.whisperService,
    required this.sentryDsn,
    required this.aiKey,
    required this.dropDatabase,
    required this.databaseName,
    required this.inMemoryDatabase,
  }) : type = EnvironmentFlavor.staging;

  const AppEnvironment.production({
    required this.version,
    required this.authService,
    required this.appService,
    required this.whisperService,
    required this.sentryDsn,
    required this.aiKey,
    required this.dropDatabase,
    required this.databaseName,
    required this.inMemoryDatabase,
  }) : type = EnvironmentFlavor.production;

  @override
  final String version;
  @override
  final EnvironmentFlavor type;
  @override
  final Uri authService;
  @override
  final Uri appService;
  @override
  final Uri whisperService;
  @override
  final String sentryDsn;
  @override
  final String aiKey;
  @override
  final bool dropDatabase;
  @override
  final String databaseName;
  @override
  final bool inMemoryDatabase;
}
