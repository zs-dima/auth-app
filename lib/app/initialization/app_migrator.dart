// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:math';

import 'package:auth_app/_core/constant/config.dart';
import 'package:auth_app/_core/database/database.dart';
import 'package:auth_app/_core/generated/constant/pubspec.yaml.g.dart';
import 'package:l/l.dart';

/// Migrate application when version is changed.
sealed class AppMigrator {
  static void migrate(Database database) {
    try {
      final prevMajor = database.getKey<int>(Config.versionMajorKey);
      final prevMinor = database.getKey<int>(Config.versionMinorKey);
      final prevPatch = database.getKey<int>(Config.versionPatchKey);
      if (prevMajor == null || prevMinor == null || prevPatch == null) {
        l.i('Initializing app for the first time');
        /* ... */
      } else if (Pubspec.version.major != prevMajor ||
          Pubspec.version.minor != prevMinor ||
          Pubspec.version.patch != prevPatch) {
        l.i(
          'Migrating from $prevMajor.$prevMinor.$prevPatch to ${Pubspec.version.major}.${Pubspec.version.minor}.${Pubspec.version.patch}',
        );
        /* ... */
      } else {
        l.i('App is up-to-date');
        return;
      }
      database.setAll(<String, int>{
        Config.versionMajorKey: Pubspec.version.major,
        Config.versionMinorKey: Pubspec.version.minor,
        Config.versionPatchKey: Pubspec.version.patch,
      });
    } on Object catch (error, stackTrace) {
      l.e('App migration failed: $e', stackTrace);
      rethrow;
    }
  }
}
