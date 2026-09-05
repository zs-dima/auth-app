import 'package:flutter_test/flutter_test.dart';

import '../tool/source_text.dart';

/// A log body is `Area | operation | message`, and nothing else.
///
/// The body is the GROUPING KEY: it is the crash reporter's fingerprint, the
/// breadcrumb's category and the first thing a support mail shows. A value
/// interpolated into it — a step name, a peer address, a room label — turns one
/// issue into one issue per value, and puts the user's own words where the
/// redaction rules cannot reach them. The values belong in `meta:`, where they
/// are queryable and where the tag whitelist decides what may leave.
///
/// This is the ratchet under the one-off sweep that made every body canonical:
/// without it the next `log.i('Pairing | connect | $endpoint failed')` compiles
/// and nothing notices for a release.
void main() {
  /// The first argument of `log(`, `log.d(` … `log.v6(`, `log.call(`, and of the two report
  /// helpers — which are how most bodies are written now, and were invisible here.
  final call = RegExp(
    r'''\b(?:log(?:\.(?:call|d|i|w|e|f|v[1-6]))?|reportFailure|reportInfo)\(\s*(['"])(.*?)\1''',
    dotAll: true,
  );

  /// A segment is either plain text or ONE whole interpolation.
  ///
  /// `'$area | call | $outcome'` is fine: `area` and `outcome` are symbolic
  /// (`Rpc`/`Http`, `ok`/`failed`), so the body still takes a handful of stable
  /// values. `'Pairing | connect | $endpoint failed'` is not — the value is
  /// spliced INTO prose, which is what makes it unbounded.
  final wholeInterpolation = RegExp(r'^\$\{?[A-Za-z_][\w.]*\}?$');

  test('every literal log body is three segments, with no value spliced in', () {
    final offenders = <String>[];

    for (final file in dartFiles()) {
      final path = pathOf(file);
      final source = withoutComments(file.readAsStringSync());
      for (final match in call.allMatches(source)) {
        final body = match.group(2)!;
        // A body forwarded whole (`log.v4(body, ...)` in `reportFailure`) was
        // already judged at ITS call site; there is nothing here to check.
        if (wholeInterpolation.hasMatch(body)) continue;

        final segments = body.split(' | ');
        final ok =
            segments.length == 3 &&
            segments.every((segment) => !segment.contains(r'$') || wholeInterpolation.hasMatch(segment)) &&
            RegExp(r'^[A-Z$]').hasMatch(segments.first);
        if (ok) continue;
        offenders.add('$path:${lineAt(source, match.start)} -> $body');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'A body is `Area | operation | message` — three segments, values in `meta:`.\n'
          'It is the crash reporter\'s fingerprint and the breadcrumb category, so a value in it\n'
          'is one issue per value.\nFound at:\n${offenders.join('\n')}',
    );
  });
}
