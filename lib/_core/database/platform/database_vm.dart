import 'dart:io' as io;

import 'package:auth_app/_core/generated/constant/pubspec.yaml.g.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart' as ffi;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as pp;
import 'package:platform_info/platform_info.dart';

Future<QueryExecutor> $createQueryExecutor(
  String databaseName, {
  String? path,
  bool logStatements = false,
  bool dropDatabase = false,
  bool memoryDatabase = false,
}) async {
  // Put this somewhere before you open your first VmDatabase

  if (kDebugMode) {
    // Close existing instances for hot restart
    try {
      // ignore: experimental_member_use — hot-restart hygiene; drift offers no stable equivalent.
      await ffi.NativeDatabase.closeExistingInstances();
    } on Object catch (e, st) {
      log.w('Database | reset | close of existing instances failed', error: e, stackTrace: st);
    }
  }

  if (memoryDatabase) {
    return ffi.NativeDatabase.memory(
      logStatements: logStatements,
      /* setup: (db) {}, */
    );
  }
  io.File file;
  if (path == null) {
    try {
      var dbFolder = await pp.getApplicationDocumentsDirectory();
      if (platform.desktop) {
        dbFolder = io.Directory(p.join(dbFolder.path, Pubspec.name));
        if (!dbFolder.existsSync()) await dbFolder.create(recursive: true);
      }
      file = io.File(p.join(dbFolder.path, '$databaseName.db'));
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace('Failed to get application documents directory "$error"', stackTrace);
    }
  } else {
    file = io.File(path);
  }
  try {
    if (dropDatabase && file.existsSync()) {
      await file.delete();
    }
  } on Object catch (e, st) {
    log.e('Database | drop | delete failed', error: e, stackTrace: st, meta: <String, Object?>{'db.path': file.path});
    rethrow;
  }
  /* return ffi.NativeDatabase(
    file,
    logStatements: logStatements,
    /* setup: (db) {}, */
  ); */
  return ffi.NativeDatabase.createInBackground(
    file,
    logStatements: logStatements,
    /* setup: (db) {}, */
  );
}
