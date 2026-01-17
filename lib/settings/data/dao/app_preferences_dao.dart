import 'package:auth_app/settings/data/preferences/preferences_entry.dart';
import 'package:auth_app/settings/data/preferences/shared_preferences_dao.dart';

final class AppPreferencesDao extends PreferencesDao {
  const AppPreferencesDao(super.driver);
  PreferencesEntry<String> get user => stringEntry('user');
  PreferencesEntry<String> get userId => stringEntry('user_id');
  PreferencesEntry<String> get userEmail => stringEntry('user_email');
  PreferencesEntry<String> get themeMode => stringEntry('theme_mode');
  PreferencesEntry<int> get themeColor => intEntry('theme_color');
  PreferencesEntry<String> get locale => stringEntry('locale');
  PreferencesEntry<double> get textScale => doubleEntry('text_scale');
  PreferencesEntry<String> get installationId => stringEntry('installation_id');
  PreferencesEntry<bool> get firstStart => boolEntry('first_start');

  PreferencesEntry<String> get credentials => stringEntry('api_credentials');
}
