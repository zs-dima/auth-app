// ignore_for_file: avoid_web_libraries_in_flutter, prefer-static-class, avoid-unused-parameters

import 'package:auth_app/_core/log/logger.dart';
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

// TODO https://github.com/flutter/flutter/issues/44937
Future<QueryExecutor> $createQueryExecutor(
  String databaseName, {
  String? path,
  bool logStatements = false,
  bool dropDatabase = false,
  bool memoryDatabase = false,
}) {
  final db = DatabaseConnection.delayed(
    Future(() async {
      final result = await WasmDatabase.open(
        databaseName: databaseName,
        sqlite3Uri: Uri.parse('/sqlite3.wasm'),
        driftWorkerUri: Uri.parse('/drift_worker.js'),
      );

      if (result.missingFeatures.isNotEmpty) {
        logger.w('Using ${result.chosenImplementation} due to missing browser features: ${result.missingFeatures}');
      }

      return result.resolvedExecutor;
    }),
  );
  return Future<QueryExecutor>.value(db);
}
