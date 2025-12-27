import 'package:auth_app/_core/settings/preferences/preferences_entry_async.dart';
import 'package:auth_app/_core/settings/preferences/secure_preferences_dao.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class AppSecurePreferencesDao extends SecurePreferencesDao {
  AppSecurePreferencesDao._(
    super.driver, {
    required UserIdCallback? getUserId,
  }) : super(
         getKeyPrefix: () async {
           if (getUserId == null) return 'NA';
           final userId = await getUserId();
           return userId.isNullOrSpace ? 'NA' : '$userId';
         },
       );
  static AppSecurePreferencesDao? _instance;

  PreferencesEntryAsync<String> get credentials => stringEntry('credentials');
  static AppSecurePreferencesDao instance(
    FlutterSecureStorage preferences, {
    required UserIdCallback? getUserId,
  }) => _instance ??= AppSecurePreferencesDao._(
    preferences,
    getUserId: getUserId,
  );
}
