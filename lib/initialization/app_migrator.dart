// ignore_for_file: avoid_classes_with_only_static_members

import 'package:auth_app/_core/constant/config.dart';
import 'package:auth_app/_core/database/database.dart';
import 'package:auth_app/_core/generated/constant/pubspec.yaml.g.dart';
import 'package:auth_app/_core/log/telemetry.dart';

/// Migrate application when version is changed.
sealed class AppMigrator {
  static String get _version => '${Pubspec.version.major}.${Pubspec.version.minor}.${Pubspec.version.patch}';

  static void migrate(Database database) {
    try {
      final prevMajor = database.getKey<int>(Config.versionMajorKey);
      final prevMinor = database.getKey<int>(Config.versionMinorKey);
      final prevPatch = database.getKey<int>(Config.versionPatchKey);
      if (prevMajor == null || prevMinor == null || prevPatch == null) {
        log.i('Migrator | install | first launch', meta: <String, Object?>{'app.version': _version});
        // Nothing to migrate on a fresh install: the schema ladder creates the
        // database and every stored value has a code default.
      } else if (Pubspec.version.major != prevMajor ||
          Pubspec.version.minor != prevMinor ||
          Pubspec.version.patch != prevPatch) {
        log.i(
          'Migrator | upgrade | version changed',
          meta: <String, Object?>{
            'app.version.previous': '$prevMajor.$prevMinor.$prevPatch',
            'app.version': _version,
          },
        );
        // No data migration is needed today: the drift schema has its own
        // ladder, and preferences are read through defaults. A future step
        // that DOES need one belongs here, with a version guard.
      } else {
        log.v4('Migrator | check | up to date', meta: <String, Object?>{'app.version': _version});
        return;
      }
      database.setAll(<String, int>{
        Config.versionMajorKey: Pubspec.version.major,
        Config.versionMinorKey: Pubspec.version.minor,
        Config.versionPatchKey: Pubspec.version.patch,
      });
    } on Object catch (error, stackTrace) {
      // `warn`: the failed step is reported once, by `composeDependencies`.
      log.w('Migrator | run | failed', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }
}
