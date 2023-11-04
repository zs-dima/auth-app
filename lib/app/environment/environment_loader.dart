import 'dart:convert';

import 'package:auth_app/app/environment/model/app_environment.dart';
import 'package:auth_app/app/environment/model/app_environment_model.dart';
import 'package:auth_app/app/environment/model/environment.dart';
import 'package:auth_app/app/environment/model/environment_variables.dart';
import 'package:auth_app/app/log/logger.dart';
import 'package:auth_app/core/gen/resources/assets.gen.dart';
import 'package:collection/collection.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform_info/platform_info.dart';

class EnvironmentLoader {
  Future<AppEnvironment>? _$currentLoading;

  EnvironmentLoader();

  Future<AppEnvironment> call() => _$currentLoading ??= Future<AppEnvironment>(() async {
        try {
          const envDefault = Environment.development;

          final dockerJsonText = await rootBundle.loadString(Assets.environment);
          // ignore: argument_type_not_assignable
          final dockerEnv = AppEnvironmentModel.fromJson(json.decode(dockerJsonText));

          final env = (dockerEnv.environment ?? const String.fromEnvironment(EnvironmentVariables.environment)) //
              .toLowerCase();

          final sentryDsn = dockerEnv.sentryDsn ?? const String.fromEnvironment(EnvironmentVariables.sentryDsn);

          final environment =
              //
              Environment.values.firstWhereOrNull((item) => item.name == env) ??
                  Platform.instance.buildMode.maybeWhen(
                    release: () => Environment.production,
                    orElse: () => envDefault,
                  );

          final packageInfo = await PackageInfo.fromPlatform();
          final authAddress = dockerEnv.authAddress ?? const String.fromEnvironment(EnvironmentVariables.authAddress);
          final apiAddress = Uri.parse(
            dockerEnv.apiAddress ?? const String.fromEnvironment(EnvironmentVariables.apiAddress),
          );

          final environmentSettings = AppEnvironment(
            dockerEnv.version ??
                const String.fromEnvironment(EnvironmentVariables.appVersion)
                    .whenEmpty('${packageInfo.version}+${packageInfo.buildNumber}'),
            environment!,
            appService: apiAddress,
            authService: authAddress.isNullOrSpace ? apiAddress : Uri.parse(authAddress),
            sentryDsn: sentryDsn,
          );
          logger.i('🚀 ${environment.name.capitalized} environment'.characters.toString());

          return environmentSettings;
        } on Exception catch (error, s) {
          logger.e('Error on loading Environment: $error\n$s', stackTrace: s);
          Error.throwWithStackTrace(error, s);
        }
      });
}
