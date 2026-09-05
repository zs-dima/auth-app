import 'dart:convert';
import 'dart:io';

/// Writes the runtime environment file the web app reads on boot
/// (`environment_loader.dart` loads `assets/environment.json` via rootBundle;
/// runtime values win over compile-time `--dart-define`s).
///
/// SECURITY: the output is served publicly by nginx, and the container's
/// environment can hold injected secrets (service-account paths, DB
/// credentials). So this tool is ALLOWLIST-ONLY — a key that is not one the
/// app consumes is skipped, never written. `deploy/entrypoint.sh` passes the
/// same allowlist from the shell side; this filter is the defense in depth.
///
/// Keep [kAllowedKeys] in sync with `EnvironmentVariables`
/// (lib/_core/environment/model/environment_variables.dart). This file is
/// compiled standalone in the Docker build (no package imports available);
/// `test/tool/web_env_test.dart` guards the two lists against drift.
const Set<String> kAllowedKeys = {
  'APP_VERSION',
  'APP_ENVIRONMENT',
  'SENTRY_DSN',
  'DB_DROP',
  'DB_NAME',
  'DB_IN_MEMORY',
  'APP_AUTH_ADDRESS',
  'APP_API_ADDRESS',
  'S3_URL',
};

void main(List<String> arguments) async {
  const webRoot = '/usr/share/nginx/html';
  const envJsonPath = '$webRoot/assets/assets/environment.json';
  const versionJsonPath = '$webRoot/version.json';

  final envJson = buildEnvironmentJson(
    arguments,
    readVersionJson: () => File(versionJsonPath).readAsStringSync(),
    warn: (message) => stderr.writeln('web-env: $message'),
  );

  final envFileContent = const JsonEncoder.withIndent('    ').convert(envJson);
  await File(envJsonPath).writeAsString(envFileContent);
}

/// Pure core, extracted so the allowlist and parsing are unit-testable
/// without the container's filesystem.
Map<String, Object> buildEnvironmentJson(
  List<String> arguments, {
  required String Function() readVersionJson,
  void Function(String message)? warn,
}) {
  final envJson = <String, Object>{};
  var appEnvironment = 'staging';

  for (final argument in arguments) {
    // Split on the FIRST '=' only: values legitimately contain '=' (URLs with
    // query strings, base64 padding). The old `split('=')` rejected the whole
    // run on any such value.
    final separator = argument.indexOf('=');
    if (separator <= 0) {
      warn?.call('skipping malformed argument (expected KEY=value): $argument');
      continue;
    }

    final key = argument.substring(0, separator).trim().toUpperCase();
    final value = argument.substring(separator + 1).trim();

    if (!kAllowedKeys.contains(key)) {
      // Never write what the app does not read — see the header. Warn, so a
      // genuinely new variable that was added to EnvironmentVariables but not
      // here is discoverable in the container logs.
      warn?.call('skipping non-allowlisted key: $key');
      continue;
    }

    if (key == 'APP_ENVIRONMENT' && value.isNotEmpty) appEnvironment = value;

    if (key == 'APP_VERSION' && value.isEmpty) {
      // Derive from the build's version.json when the deployment did not set
      // one: "<version>b<build><env-initial>".
      final versionJson = jsonDecode(readVersionJson()) as Map<String, Object?>;
      envJson[key] = '${versionJson['version']}b${versionJson['build_number']}${appEnvironment[0]}'.trim();
      continue;
    }

    if (value.isEmpty) continue; // an empty value cannot override a dart-define

    envJson[key] = _toJsonValue(value);
  }

  return envJson;
}

/// Converts a string to a JSON value.
Object _toJsonValue(String value) => switch (value) {
  _ when int.tryParse(value) != null => int.parse(value),
  _ when double.tryParse(value) != null => double.parse(value),
  _ when value.toLowerCase() == 'true' => true,
  _ when value.toLowerCase() == 'false' => false,
  _ => value,
};
