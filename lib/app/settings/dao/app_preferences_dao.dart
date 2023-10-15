import 'package:auth_app/app/settings/preferences/preferences_entry.dart';
import 'package:auth_app/app/settings/preferences/shared_preferences_dao.dart';

final class AppPreferencesDao extends PreferencesDao {
  AppPreferencesDao(super.driver);

  PreferencesEntry<String> get user => stringEntry('user');
  PreferencesEntry<String> get themeMode => stringEntry('theme_mode');
  PreferencesEntry<int> get themeColor => intEntry('theme_color');
  PreferencesEntry<String> get locale => stringEntry('locale');
  PreferencesEntry<String> get installationId => stringEntry('installation_id');
  PreferencesEntry<bool> get firstStart => boolEntry('first_start');
}
