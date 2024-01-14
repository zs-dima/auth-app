class EnvironmentVariables {
  static const sentryDsn = 'SENTRY_DSN';

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

  // --- API --- //

  static const authAddress = 'APP_AUTH_ADDRESS';
  static const apiAddress = 'APP_API_ADDRESS';
}
