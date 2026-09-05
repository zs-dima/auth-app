import 'package:auth_app/_core/log/console.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/source_text.dart';

/// A release console is a device log, and a device log has no consent.
///
/// `adb logcat`, a bug-report tool, anything with `READ_LOGS` on a rooted phone — no redaction,
/// no expiry, no way for the user to say no. The `debug` lines this app writes are controller
/// transitions whose attributes carry state renderings: a pairing state holds the four-digit
/// code, a mapping state holds the words the user wrote for the rooms in their home. So release
/// stops at `info`.
///
/// `docs/decisions.md` cites this as a promise, and the twin app cited it for a day while only
/// this one actually had it — the promise now has a test in both.
void main() {
  test('the console floor is info in release and trace in debug', () {
    // A CONSTANT of the build, so it cannot be read at runtime from a debug test — the source is
    // where the decision lives, and the source is what this reads. The sink's behaviour given a
    // floor is covered by the package's own tests.
    final source = withoutComments(
      dartFiles().firstWhere((file) => pathOf(file).endsWith('_core/log/console.dart')).readAsStringSync(),
    );

    expect(
      source,
      contains('minLevel: kReleaseMode ? LogLevel.info : LogLevel.trace'),
      reason:
          'A release build must not print debug lines to the device log: they carry state\n'
          'renderings — the pairing code, the labels for rooms in the user\'s home.',
    );
  });

  test('the options this app builds keep trace tiers off the console', () {
    // The other half: `maxVerbosity` is a PRINT dial and nothing more. The ring buffer keeps
    // every trace line regardless, which is what the dev menu reads — including in release,
    // where the floor above means the console shows none of them.
    expect(kConsoleOptions.maxVerbosity, lessThan(5));
    expect(kConsoleOptions.outputInRelease, isTrue, reason: 'a tester reading a device log is a reader too');
  });
}
