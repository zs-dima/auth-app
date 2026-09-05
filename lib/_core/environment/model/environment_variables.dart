abstract final class EnvironmentVariables {
  static const sentryDsn = 'SENTRY_DSN';
  // AI_KEY / WHISPER_ADDRESS removed 2026-09-02: zero consumers in lib/, yet the live key was
  // const-folded into every artifact via String.fromEnvironment (docs/decisions.md).

  // --- APP --- //

  static const appVersion = 'APP_VERSION';
  static const environment = 'APP_ENVIRONMENT';

  // --- DATABASE --- //

  /// Whether to drop database on start.
  static const dropDatabase = 'DB_DROP';

  /// Database file name by default.
  /// e.g. sqlite means "sqlite.db" for native platforms and "sqlite" for web platform.
  static const databaseName = 'DB_NAME';

  /// Whether to use in-memory database.
  static const inMemoryDatabase = 'DB_IN_MEMORY';

  // --- STORAGE --- //
  /// S3 storage URL including bucket name.
  static const s3Url = 'S3_URL';

  // --- API --- //

  static const authAddress = 'APP_AUTH_ADDRESS';
  static const apiAddress = 'APP_API_ADDRESS';
}
