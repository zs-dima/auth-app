import 'package:auth_app/_core/theme/theme_mode_codec.dart';
import 'package:auth_app/settings/data/dao/app_preferences_dao.dart';
import 'package:auth_app/settings/data/dao/app_secure_preferences_dao.dart';
import 'package:auth_app/settings/data/settings_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

AccessCredentials _creds(String token) => .new(
  accessToken: AccessToken(token: token, expiry: DateTime.utc(2030)),
  refreshToken: RefreshToken('r-$token'),
);

/// In-memory backing for the flutter_secure_storage platform channel, so the REAL SettingsRepository
/// (over the real DAOs) can be exercised without a device keychain.
const _secureChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> secureStore;
  late int secureWrites;

  Future<SettingsRepository> buildRepository() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsRepository(
      preferences: AppPreferencesDao(prefs),
      securePreferences: const AppSecurePreferencesDao(FlutterSecureStorage()),
      codec: const ThemeModeCodec(),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    secureStore = <String, String>{};
    secureWrites = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_secureChannel, (
      call,
    ) async {
      final args = (call.arguments as Map).cast<String, Object?>();
      final key = args['key'] as String?;
      switch (call.method) {
        case 'read':
          return secureStore[key];

        case 'write':
          secureWrites++;
          secureStore[key!] = args['value']! as String;
          return null;

        case 'delete':
          secureStore.remove(key);
          return null;

        case 'containsKey':
          return secureStore.containsKey(key);

        case 'readAll':
          return Map<String, String>.of(secureStore);

        case 'deleteAll':
          secureStore.clear();
          return null;

        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_secureChannel, null);
  });

  group('SettingsRepository.setCredentials (corrupt-blob resilience — F2)', () {
    test('setCredentials(null) removes a corrupt blob instead of throwing', () async {
      secureStore['credentials'] = '{ not valid json';
      final repo = await buildRepository();

      await expectLater(repo.setCredentials(null), completes);
      expect(secureStore.containsKey('credentials'), isFalse);
    });

    test('setCredentials(value) overwrites a corrupt blob (self-healing)', () async {
      secureStore['credentials'] = '{ not valid json';
      final repo = await buildRepository();

      await repo.setCredentials(_creds('A'));

      final restored = await repo.getCredentials();
      expect(restored?.accessToken.token, equals('A'));
    });

    test('setCredentials then getCredentials round-trips', () async {
      final repo = await buildRepository();

      await repo.setCredentials(_creds('A'));
      final restored = await repo.getCredentials();

      expect(restored, equals(_creds('A')));
    });

    test('getCredentials returns null when nothing is stored', () async {
      final repo = await buildRepository();
      expect(await repo.getCredentials(), isNull);
    });

    test('a value-equal rewrite is skipped (dedup guard)', () async {
      final repo = await buildRepository();

      await repo.setCredentials(_creds('A'));
      final writesAfterFirst = secureWrites;

      await repo.setCredentials(_creds('A')); // value-equal → must not hit secure storage again

      expect(secureWrites, equals(writesAfterFirst), reason: 'an identical rewrite must be skipped');
      expect((await repo.getCredentials())?.accessToken.token, equals('A'));
    });
  });

  group('SettingsRepository.getCredentials (secret hygiene — §13)', () {
    test('a corrupt blob throws a sanitized error carrying no blob bytes', () async {
      // Truncated mid-token: `json.decode`'s FormatException would otherwise hold the WHOLE
      // decrypted blob in `source` and print a slice of it from toString() — which warning-level
      // logging forwards to Sentry.
      secureStore['credentials'] = '{"accessToken":{"type":"Bearer","data":"SECRET-ACCESS-TOKEN"';
      final repo = await buildRepository();

      await expectLater(
        repo.getCredentials(),
        throwsA(isA<FormatException>().having((e) => '$e', 'toString()', isNot(contains('SECRET')))),
      );
    });

    test('valid JSON with a wrong shape also throws sanitized', () async {
      secureStore['credentials'] = '{"accessToken":"SECRET-FLAT-STRING"}';
      final repo = await buildRepository();

      await expectLater(
        repo.getCredentials(),
        throwsA(isA<FormatException>().having((e) => '$e', 'toString()', isNot(contains('SECRET')))),
      );
    });
  });
}
