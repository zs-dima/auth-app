// ignore_for_file: avoid_classes_with_only_static_members

/// Config for app.
abstract final class Config {
  // --- APP --- //

  static const appName = String.fromEnvironment('APP_NAME', defaultValue: 'Auth app');

  // --- AUTHENTICATION --- //

  /// Minimum length of password.
  /// e.g. 5
  static const passwordMinLength = int.fromEnvironment('PASSWORD_MIN_LENGTH', defaultValue: 5);

  /// Maximum length of password.
  /// e.g. 32
  static const passwordMaxLength = int.fromEnvironment('PASSWORD_MAX_LENGTH', defaultValue: 32);

  // --- LAYOUT --- //

  /// Maximum screen layout width for screen with list view.
  static const maxScreenLayoutWidth = int.fromEnvironment('MAX_LAYOUT_WIDTH', defaultValue: 768);

  // --- Key storage namespace --- //

  /// Namespace for all version keys
  static const storageNamespace = 'keys';

  /// Keys for storing the current version of the app
  static const versionMajorKey = '$storageNamespace.version.major';

  /// Keys for storing the current version of the app
  static const versionMinorKey = '$storageNamespace.version.minor';

  /// Keys for storing the current version of the app
  static const versionPatchKey = '$storageNamespace.version.patch';
}
