// Architecture guard: rest_client is a *portable* HTTP client and web is a shipping target, so its
// `lib/` must never import `dart:ui` (couples to the Flutter engine) or `dart:html`. `dart:io` is
// permitted ONLY in the conditionally-imported VM platform file (`src/platform/http_client_vm.dart`);
// the web build selects `http_client_js.dart` (dart:js_interop) instead — see the conditional import
// in `api_client.dart`. This fails fast if a platform import sneaks into the shared code — the exact
// regression that let `dart:ui` slip into BearerAuthenticationMiddleware (A1).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rest_client lib stays portable (dart:io only in the platform layer; never dart:ui/dart:html)', () {
    // dart:ui / dart:html: never allowed anywhere in lib.
    final bannedEverywhere = RegExp(r'''import\s+['"]dart:(ui|html)['"]''');
    // dart:io: allowed ONLY in the conditionally-imported VM platform file, never in shared code.
    final bannedIo = RegExp(r'''import\s+['"]dart:io['"]''');
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      // Normalize separators so the platform-layer allowance holds on Windows and POSIX alike.
      final isPlatformLayer = entity.path.replaceAll(r'\', '/').contains('/src/platform/');
      for (final (index, line) in entity.readAsLinesSync().indexed) {
        if (bannedEverywhere.hasMatch(line)) {
          offenders.add('${entity.path}:${index + 1}  ${line.trim()}');
        } else if (!isPlatformLayer && bannedIo.hasMatch(line)) {
          offenders.add('${entity.path}:${index + 1}  ${line.trim()}  (dart:io allowed only in src/platform/)');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'rest_client must stay portable (web target; Flutter-engine-free core). '
          'Offending imports:\n${offenders.join('\n')}',
    );
  });
}
