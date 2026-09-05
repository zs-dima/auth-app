// ignore_for_file: avoid_relative_lib_imports
import 'package:auth_app/_core/environment/model/environment_variables.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/web_env.dart';

void main() {
  group('web-env allowlist', () {
    test('matches EnvironmentVariables exactly — the two lists must not drift', () {
      // tool/web_env.dart is compiled standalone in the Docker build and cannot
      // import the app package, so it carries its own copy of the list. THIS
      // test is the only thing keeping the copies in sync.
      const declared = <String>{
        EnvironmentVariables.appVersion,
        EnvironmentVariables.environment,
        EnvironmentVariables.sentryDsn,
        EnvironmentVariables.dropDatabase,
        EnvironmentVariables.databaseName,
        EnvironmentVariables.inMemoryDatabase,
        EnvironmentVariables.authAddress,
        EnvironmentVariables.apiAddress,
        EnvironmentVariables.s3Url,
      };
      expect(kAllowedKeys, equals(declared));
    });

    test('a non-allowlisted key is never written — the public-JSON leak guard', () {
      final warnings = <String>[];
      final json = buildEnvironmentJson(
        ['DB_PASS=hunter2', 'KUBERNETES_SERVICE_HOST=10.0.0.1', 'APP_API_ADDRESS=https://api.example'],
        readVersionJson: () => '{}',
        warn: warnings.add,
      );
      expect(json.keys, equals(['APP_API_ADDRESS']));
      expect(warnings, hasLength(2));
      expect(warnings.first, contains('DB_PASS'));
    });

    test("a value containing '=' survives intact (URLs, base64 padding)", () {
      // The previous split('=') rejected the whole run on any such value.
      final json = buildEnvironmentJson(
        ['APP_API_ADDRESS=https://api.example/ws?format=i16&key=abc=='],
        readVersionJson: () => '{}',
      );
      expect(json['APP_API_ADDRESS'], 'https://api.example/ws?format=i16&key=abc==');
    });

    test('empty values are skipped, so they cannot mask a compile-time define', () {
      final json = buildEnvironmentJson(
        ['SENTRY_DSN=', 'DB_NAME=sqlite'],
        readVersionJson: () => '{}',
      );
      expect(json.containsKey('SENTRY_DSN'), isFalse);
      expect(json['DB_NAME'], 'sqlite');
    });

    test('empty APP_VERSION derives from version.json with the environment initial', () {
      final json = buildEnvironmentJson(
        ['APP_ENVIRONMENT=production', 'APP_VERSION='],
        readVersionJson: () => '{"version":"1.2.3","build_number":"45"}',
      );
      expect(json['APP_VERSION'], '1.2.3b45p');
    });

    test('booleans and numbers are typed, not stringly', () {
      final json = buildEnvironmentJson(
        ['DB_DROP=true', 'DB_IN_MEMORY=false'],
        readVersionJson: () => '{}',
      );
      expect(json['DB_DROP'], isTrue);
      expect(json['DB_IN_MEMORY'], isFalse);
    });
  });
}
