import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The vendored web binaries (web/drift_worker.js, web/sqlite3.wasm) are precompiled artifacts
/// tied to the pinned drift/sqlite3 packages. This gate fails when a dependency bump leaves the
/// binaries behind — refresh them and update web/drift_assets.lock in the same change.
void main() {
  test('vendored drift worker + sqlite3 wasm match the pinned package versions', () {
    final lockLines = File('web/drift_assets.lock').readAsLinesSync();
    final pins = <String, String>{
      for (final line in lockLines)
        if (!line.startsWith('#') && line.trim().isNotEmpty) line.split(' ').first: line.split(' ').last,
    };
    expect(pins.keys, containsAll(<String>['drift', 'sqlite3']));

    final pubspecLock = File('pubspec.lock').readAsStringSync();
    for (final MapEntry(:key, :value) in pins.entries) {
      // `\r?\n`, not `\n`: `pubspec.lock` is tracked and this repository has no `.gitattributes`,
      // so a fresh checkout under `core.autocrlf=true` writes CRLF and an LF-only pattern would
      // report "drift not found in pubspec.lock" on a clean clone.
      final match = RegExp(
        '^  $key:\r?\n(?:.*\r?\n)*?    version: "([^"]+)"',
        multiLine: true,
      ).firstMatch(pubspecLock);
      expect(match, isNotNull, reason: '$key not found in pubspec.lock');
      expect(
        match!.group(1),
        value,
        reason:
            '$key was bumped to ${match.group(1)} but web/drift_assets.lock still pins $value — '
            'refresh web/drift_worker.js + web/sqlite3.wasm and update the lock file.',
      );
    }

    expect(File('web/drift_worker.js').existsSync(), isTrue);
    expect(File('web/sqlite3.wasm').existsSync(), isTrue);
  });
}
