import 'package:flutter_test/flutter_test.dart';

import '../../tool/checks/flutter_layout_check.dart';

/// The layout doctrine, enforced where CI can see it.
///
/// The check itself is `tool/checks/flutter_layout_check.dart`, which the local Stop hook also
/// runs — but that hook is a developer's machine only. CI is Linux with no dev-tools plugin, so
/// without this test the two structural laws were guarded nowhere that could block a merge.
///
/// Imported, not spawned. Running it as `dart run` from a test costs a compile and a whole tree
/// walk in a process already competing with the suite for cores; the first version did exactly
/// that and pushed a neighbouring subprocess test past its own 30-second timeout.
void main() {
  test('lib/ and packages/ are clean under the layout check', () {
    final findings = scanProject();
    expect(
      findings,
      isEmpty,
      reason:
          'Layout check findings:\n'
          '${findings.map((f) => '  ${f.file}:${f.line}: ${f.rule} — ${f.text.trim()}').join('\n')}\n'
          'The rules and their fixes are in the `flutter-layout-perf` skill. A false positive is '
          'silenced with `// layout-check: ignore <rule>` on the line or the line above.',
    );
  });
}
