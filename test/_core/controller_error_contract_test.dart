import 'package:flutter_test/flutter_test.dart';

import 'tool/source_text.dart';

/// Every `handle(...)` in `lib/` must say what happens when it throws.
///
/// `control`'s `error:` is optional, and an omitted one is silent: the handler's failure reaches
/// `ControllerObserver.onError` (so it is journaled) and then nothing else happens — the state
/// stays exactly as the last `setState` left it. That is how the paywall sat on `loading` forever
/// when the store threw, and how a mapping save that never reached the database looked, on screen,
/// exactly like a save that did.
///
/// A required parameter would be the natural way to enforce this, but Dart forbids narrowing an
/// inherited optional named parameter to a required one, so an `AppController` override cannot
/// express it. This test does — including for controllers nobody has written yet.
void main() {
  /// How many controller files the scan must find before its silence means anything.
  ///
  /// The file filter is a heuristic (`extends StateController` as text), and a base class
  /// extracted one refactor from now would take every controller out of scope at once — leaving a
  /// green test that reads nothing. The floor is deliberately far below today's count: it is a
  /// tripwire for "the filter stopped matching", not a target.
  const minimumScanned = 5;

  /// And how many CALL SITES. The file count alone is not enough: a rewrite of the
  /// declaration-vs-call rule once put `>` in the "declaration" class, which made every
  /// `=> handle(` — that is, every call in this codebase — a skip, and the test stayed green
  /// while checking nothing at all. This counts what it actually judged.
  const minimumChecked = 20;

  test('every handle() passes an error callback', () {
    final offenders = <String>[];
    var scanned = 0;
    var checked = 0;

    for (final file in dartFiles()) {
      final path = pathOf(file);
      final source = withoutComments(file.readAsStringSync());
      // Only controllers. `handle` is also the name of a middleware's own entry point
      // (`ConnectMiddleware.handle`) and of a telemetry sink's (`TelemetrySink.handle`), and
      // neither has an `error:` to pass — the contract is about `control`'s optional callback.
      if (!source.contains('extends StateController')) continue;
      scanned++;
      var index = 0;
      while (true) {
        final start = source.indexOf('handle(', index);
        if (start < 0) break;
        index = start + 'handle('.length;

        // A DECLARATION, not a call: `void handle(LogEvent event)` has a return type in front of
        // it. A call is `=> handle(`, `return handle(`, `await handle(`, `? handle(` — or a
        // statement on its own.
        //
        // `=>` is the case that has broken this test twice. It ends with `>`, the same character
        // a generic return type ends with (`Future<void> handle(`), so a rule that reads only
        // the last character calls every arrow-bodied member a declaration — and every handler
        // in this codebase is arrow-bodied. The arrow is checked FIRST, before the character.
        // ignore: avoid-substring — ASCII source positions, not user text.
        final before = source.substring(0, start).trimRight();
        final isArrow = before.endsWith('=>');
        final previous = before.isEmpty ? '' : before[before.length - 1];
        final isWord = !isArrow && RegExp('[A-Za-z0-9_>]').hasMatch(previous);
        final keyword = isWord && RegExp(r'\b(return|await|yield)$').hasMatch(before);
        if (isWord && !keyword) continue;
        checked++;

        // Walk to the matching close paren so nested calls and closures are skipped correctly.
        var depth = 1;
        var cursor = index;
        while (cursor < source.length && depth > 0) {
          final char = source[cursor];
          if (char == '(') {
            depth++;
          } else if (char == ')') {
            depth--;
          }
          cursor++;
        }

        // ignore: avoid-substring — ASCII source positions, not user text.
        final arguments = source.substring(index, cursor);
        if (RegExp(r'^\s*error:', multiLine: true).hasMatch(arguments)) continue;
        offenders.add('$path:${lineAt(source, start)}');
      }
    }

    expect(
      scanned,
      greaterThanOrEqualTo(minimumScanned),
      reason:
          'Only $scanned controller files matched `extends StateController`.\n'
          'If controllers now extend an app base class, teach this test its name — otherwise it\n'
          'passes by reading nothing.',
    );
    expect(
      checked,
      greaterThanOrEqualTo(minimumChecked),
      reason:
          'Only $checked `handle(` call sites were judged, out of $scanned controller files.\n'
          'The declaration-vs-call rule above has stopped recognising calls — which is exactly\n'
          'how this test once passed while checking none of them.',
    );
    expect(
      offenders,
      isEmpty,
      reason:
          'A handler with no `error:` fails silently and leaves the screen as it was.\n'
          'Add one — even if it only logs — at:\n${offenders.join('\n')}',
    );
  });
}
