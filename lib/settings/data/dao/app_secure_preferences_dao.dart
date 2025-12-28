import 'package:auth_app/settings/data/preferences/preferences_entry_async.dart';
import 'package:auth_app/settings/data/preferences/secure_preferences_dao.dart';

final class AppSecurePreferencesDao extends SecurePreferencesDao {
  const AppSecurePreferencesDao(super.driver);
  // AppSecurePreferencesDao._(super.driver, {required UserIdCallback getUserId})
  //   : super(
  //       getKeyPrefix: () async {
  //         final userId = await getUserId() ?? 0;
  //         return userId <= 0 ? 'NA' : '$userId';
  //       },
  //     );

  // factory AppSecurePreferencesDao.instance(FlutterSecureStorage preferences, {required UserIdCallback getUserId}) =>
  //     _instance ??= AppSecurePreferencesDao._(preferences, getUserId: getUserId);
  // static AppSecurePreferencesDao? _instance;

  PreferencesEntryAsync<String> get credentials => stringEntry('credentials');
}
