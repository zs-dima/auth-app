// Architecture guard: auth_model is consumed on web (gRPC-web), so its `lib/` must never import
// `dart:io`, `dart:ui` or `dart:html` directly — those break the web build (A1) or couple the
// model layer to the Flutter engine. Use platform-neutral typedefs / plain constants instead.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auth_model lib stays platform-agnostic (no dart:io/dart:ui/dart:html)', () {
    final banned = RegExp(r'''import\s+['"]dart:(io|ui|html)['"]''');
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.contains('.pb')) continue; // generated proto
      for (final (index, line) in entity.readAsLinesSync().indexed) {
        if (banned.hasMatch(line)) offenders.add('${entity.path}:${index + 1}  ${line.trim()}');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'auth_model must stay platform-agnostic (web target). Offending imports:\n${offenders.join('\n')}',
    );
  });
}
