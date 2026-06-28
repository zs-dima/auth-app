// Architecture guard: grpc_model is a platform-agnostic transport package and web is a
// shipping target, so its `lib/` must never import `dart:io`, `dart:ui` or `dart:html`
// directly. Platform-specific code lives behind conditional imports (see client/channel.dart).
// This test fails fast if a platform import sneaks back in (regression guard for A1).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('grpc_model lib stays platform-agnostic (no dart:io/dart:ui/dart:html)', () {
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
      reason: 'grpc_model must stay platform-agnostic (web target). Offending imports:\n${offenders.join('\n')}',
    );
  });
}
