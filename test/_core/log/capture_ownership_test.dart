import 'package:flutter_test/flutter_test.dart';

import '../tool/source_text.dart';

/// One place decides what becomes a crash-reporter issue.
///
/// `Sentry.capture*` is what files one, and the only file allowed to call it is
/// the crash-reporting sink — where the level, the dedupe, the rate limit and
/// the tag whitelist all apply.
///
/// This is a grep test because the defect it guards was invisible to every
/// other kind. The transport Sentry middlewares captured too, independently of
/// the pipeline and of each other, so a warn-class outage still filed one issue
/// per call and an error-class failure filed TWO with different fingerprints —
/// the middleware sends the bare `ConnectException`, the pipeline sends the
/// `RpcException` chain, and Sentry's deduplication keys on the throwable's
/// hash. Nothing failed, nothing was slow, and the issue stream was noise.
void main() {
  /// All three, not `captureException` alone: `captureMessage` files an issue
  /// with no throwable at all, and `captureEvent` files a hand-built one — the
  /// two ways round a check that named only the third.
  final capture = RegExp(r'Sentry\.capture(Exception|Message|Event)\b');

  test('only the crash-reporting sink captures', () {
    const owner = 'lib/_core/log/sentry_sink.dart';
    final offenders = <String>[];

    for (final file in dartFiles()) {
      final path = pathOf(file);
      if (path.endsWith(owner)) continue;

      final source = withoutComments(file.readAsStringSync());
      for (final match in capture.allMatches(source)) {
        offenders.add('$path:${lineAt(source, match.start)} -> ${match.group(0)}');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Report through the pipeline instead: `log(...).cause(e)..error()`, or\n'
          '`..escalate(level: .error)` when the line is logged at a lighter level.\n'
          'A capture outside $owner skips the dedupe, the rate limit and the tag\n'
          'whitelist.\nFound at:\n${offenders.join('\n')}',
    );
  });
}
