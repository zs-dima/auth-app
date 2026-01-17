import 'dart:convert';

import 'package:auth_app/_core/environment/model/app_environment.dart';
import 'package:auth_app/_core/environment/model/app_environment_model.dart';
import 'package:auth_app/_core/environment/model/environment.dart';
import 'package:auth_app/_core/environment/model/environment_variables.dart';
import 'package:auth_app/_core/generated/resources/assets.gen.dart';
import 'package:auth_app/_core/log/logger.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
// import 'package:package_info_plus/package_info_plus.dart';

class EnvironmentLoader {
  Future<AppEnvironment>? _$currentLoading;

  Future<AppEnvironment> call() => _$currentLoading ??= Future<AppEnvironment>(() async {
    try {
      final dockerJsonText = await rootBundle.loadString(Assets.environment);
      // ignore: argument_type_not_assignable
      final dockerEnv = AppEnvironmentModel.fromJson(json.decode(dockerJsonText));

      final env =
          dockerEnv.environment ??
          const String.fromEnvironment(EnvironmentVariables.environment).whenEmpty(
            const String.fromEnvironment(
              'ENVIRONMENT',
            ).whenEmpty(const String.fromEnvironment('FLUTTER_APP_FLAVOR')),
          );
      final environment = EnvironmentFlavor.from(env);

      final dropDatabase =
          dockerEnv.dropDatabase ?? const bool.fromEnvironment(EnvironmentVariables.dropDatabase, defaultValue: false);
      final databaseName =
          dockerEnv.databaseName ?? //
          const String.fromEnvironment(EnvironmentVariables.databaseName, defaultValue: 'sqlite');
      final inMemoryDatabase =
          dockerEnv.inMemoryDatabase ??
          const bool.fromEnvironment(EnvironmentVariables.inMemoryDatabase, defaultValue: false);

      final sentryDsn = dockerEnv.sentryDsn ?? const String.fromEnvironment(EnvironmentVariables.sentryDsn);

      final aiKey = dockerEnv.aiKey ?? const String.fromEnvironment(EnvironmentVariables.aiKey);

      // final packageInfo = await PackageInfo.fromPlatform();
      final authAddress = dockerEnv.authAddress ?? const String.fromEnvironment(EnvironmentVariables.authAddress);
      final apiAddress = Uri.parse(
        dockerEnv.apiAddress ?? const String.fromEnvironment(EnvironmentVariables.apiAddress),
      );

      final whisperService = Uri.parse(
        dockerEnv.whisperAddress ?? const String.fromEnvironment(EnvironmentVariables.whisperAddress),
      );

      final environmentSettings = AppEnvironment(
        dockerEnv.version ?? const String.fromEnvironment(EnvironmentVariables.appVersion),
        // TODO .whenEmpty(Pubspec.version.representation),
        environment,
        appService: apiAddress,
        authService: authAddress.isNullOrSpace ? apiAddress : Uri.parse(authAddress),
        whisperService: whisperService,
        sentryDsn: sentryDsn,
        aiKey: aiKey,
        s3Url: dockerEnv.s3Url ?? const String.fromEnvironment(EnvironmentVariables.s3Url),
        dropDatabase: dropDatabase,
        databaseName: databaseName,
        inMemoryDatabase: inMemoryDatabase,
      );
      logger.i('🚀 ${environment.name.capitalized} environment'.characters.toString());

      return environmentSettings;
    } on Exception catch (error, s) {
      logger.e('Error on loading environment', error: error, stackTrace: s);
      Error.throwWithStackTrace(error, s);
    }
  });
}
