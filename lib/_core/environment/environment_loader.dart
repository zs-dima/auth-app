import 'dart:convert';

import 'package:auth_app/_core/environment/model/app_environment.dart';
import 'package:auth_app/_core/environment/model/app_environment_model.dart';
import 'package:auth_app/_core/environment/model/environment.dart';
import 'package:auth_app/_core/environment/model/environment_variables.dart';
import 'package:auth_app/_core/environment/platform/service_override.dart';
import 'package:auth_app/_core/generated/resources/assets.gen.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/services.dart';

// import 'package:package_info_plus/package_info_plus.dart';

/// localStorage keys read outside production to point a web build at another
/// backend. Namespaced by app, because the origin is shared with whatever else
/// is hosted on it.
const String _kApiOverrideKey = 'auth_app.api_base_url';
const String _kAuthOverrideKey = 'auth_app.auth_base_url';

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

      // final packageInfo = await PackageInfo.fromPlatform();
      final authAddress = dockerEnv.authAddress ?? const String.fromEnvironment(EnvironmentVariables.authAddress);
      final apiAddress = Uri.parse(
        dockerEnv.apiAddress ?? const String.fromEnvironment(EnvironmentVariables.apiAddress),
      );

      // A web build bakes its addresses in, so pointing one at another backend meant rebuilding it.
      // Outside production a localStorage key does it instead (see `service_override_js.dart`);
      // production ignores the keys entirely, so a planted value cannot redirect a real user's
      // credentials somewhere else.
      final apiOverride = environment.isProduction ? null : _overrideAddress($serviceOverride(_kApiOverrideKey));
      final authOverride = environment.isProduction ? null : _overrideAddress($serviceOverride(_kAuthOverrideKey));
      if (apiOverride != null || authOverride != null) {
        log.w(
          'Environment | override | service address',
          meta: <String, Object?>{
            if (apiOverride != null) 'app.environment.api_override': apiOverride.toString(),
            if (authOverride != null) 'app.environment.auth_override': authOverride.toString(),
          },
        );
      }

      final appService = apiOverride ?? apiAddress;
      final environmentSettings = AppEnvironment(
        dockerEnv.version ?? const String.fromEnvironment(EnvironmentVariables.appVersion),
        // TODO .whenEmpty(Pubspec.version.representation),
        environment,
        appService: appService,
        authService: authOverride ?? (authAddress.isNullOrSpace ? appService : Uri.parse(authAddress)),
        sentryDsn: sentryDsn,
        s3Url: dockerEnv.s3Url ?? const String.fromEnvironment(EnvironmentVariables.s3Url),
        dropDatabase: dropDatabase,
        databaseName: databaseName,
        inMemoryDatabase: inMemoryDatabase,
      );
      log.i('Environment | load | ready', meta: <String, Object?>{'app.environment': environment.name});

      return environmentSettings;
    } on Exception catch (error, s) {
      // `warn`, not `error`: `composeDependencies` reports the failed step, and
      // that is the incident. This line is its detail.
      log.w('Environment | load | failed', error: error, stackTrace: s);
      Error.throwWithStackTrace(error, s);
    }
  });
}

/// A service-address override, or `null` when there is none to apply.
///
/// `Uri.tryParse('')` succeeds — it yields a scheme-less, host-less `Uri` — so a
/// plain `?? baseAddress` fallback would silently shadow the configured address
/// with an empty one and every RPC would fail on an unsupported scheme.
/// Only an absolute http(s) URL may replace a baked-in address.
Uri? _overrideAddress(String? value) {
  final address = value?.trim();
  if (address == null || address.isEmpty) return null;
  final uri = Uri.tryParse(address);
  if (uri == null || !uri.hasScheme || !uri.hasAuthority) return null;
  return uri.isScheme('http') || uri.isScheme('https') ? uri : null;
}
