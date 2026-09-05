import 'package:flutter_test/flutter_test.dart';
import 'package:telemetry/telemetry.dart';

import '../tool/source_text.dart';

/// Attribute keys are a QUERY SURFACE, so their spelling is a contract.
///
/// The convention is OpenTelemetry's: lowercase, dot-namespaced, `snake_case`
/// inside a segment (`app.pairing.attempt`, `rpc.status_code`). It is what lets
/// a reader filter a journal, and it is also what the crash reporter's tag
/// whitelist matches on — a key spelled `rpc.statusCode` in one call site is
/// simply not sent, silently, forever.
void main() {
  /// EVERY `<String, Object?>{` literal, not only the ones after `meta:`.
  ///
  /// An attribute map is often built as a variable and passed a line later
  /// (`logger_middleware.dart` does exactly that), and those were invisible to
  /// the narrower pattern — which is where the one wrong key actually was.
  /// Attribute maps in this app are always typed that way, so the type is a
  /// better anchor than the parameter name.
  final attributeMap = RegExp(r'<String, Object\?>\s*\{');
  final key = RegExp(r"'([^']+)'\s*:");
  // The package's own pattern, exported for exactly this: the rule the runtime
  // asserts in `.meta({...})` and the rule this scan applies to source cannot
  // drift apart if they are the same object. It is slightly stricter than the
  // copy that used to live here — a segment may not start with a digit.
  final wellFormed = kAttributeKey;

  test('every literal attribute key is lowercase, dotted and snake_cased', () {
    final offenders = <String>[];

    for (final file in dartFiles()) {
      final path = pathOf(file);
      // Comments blanked: a doc comment writing out an example map (`{'a.B': 1}`)
      // is prose, and the one thing this test must not do is report prose.
      final source = withoutComments(file.readAsStringSync());
      for (final call in attributeMap.allMatches(source)) {
        // Only as far as the closing brace of this map: the keys after it belong
        // to whatever comes next.
        var depth = 1;
        var cursor = call.end;
        while (cursor < source.length && depth > 0) {
          final char = source[cursor];
          if (char == '{') {
            depth++;
          } else if (char == '}') {
            depth--;
          }
          cursor++;
        }

        // ignore: avoid-substring — ASCII source positions, not user text.
        final body = source.substring(call.end, cursor);
        for (final match in key.allMatches(body)) {
          final name = match.group(1)!;
          // An interpolated key is composed at runtime (`control.meta.$key`);
          // its literal prefix is what this can check, and it is well formed.
          if (name.contains(r'$')) continue;
          // Only DOTTED names are judged. A ternary VALUE inside the map reads
          // as `'lost' :` to this regex, and an undotted string in an attribute
          // map is a value, never a key — every attribute name in this app is
          // namespaced. What the rule is actually for is the near-miss:
          // `rpc.statusCode` and `app.Route` still land here.
          if (!name.contains('.')) continue;
          if (wellFormed.hasMatch(name)) continue;
          offenders.add('$path:${lineAt(source, call.start + match.start)} -> $name');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Attribute keys are lowercase, dot-namespaced and snake_case within a segment '
          '(app.pairing.attempt, rpc.status_code).\nOffending keys:\n${offenders.join('\n')}',
    );
  });
}
