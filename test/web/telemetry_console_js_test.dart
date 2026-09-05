@TestOn('browser')
library;

// Browser-platform test for the telemetry console's web delegate. Run with:
//   flutter test --platform chrome test/web
// (wired into the code-analysis workflow).
//
// This is the ONLY thing that compiles `delegate_js.dart`. It is selected by a conditional
// import on `dart.library.js_interop`, so the VM suite never sees it: a typo in one of the
// `external void warn(JSAny?)` bindings, or a level the switch forgot, would ship to the web
// build and be discovered by a developer with an empty browser console.

import 'package:flutter_test/flutter_test.dart';
import 'package:telemetry/telemetry.dart';

void main() {
  group('the browser console delegate', () {
    test('is what the pipeline picks on the web, and every level reaches it', () {
      final lines = <({LogLevel level, String line})>[];
      Telemetry(runId: 'run-web')
        ..addSink(
          ConsoleSink(
            options: const TelemetryOptions(printColors: false, showTime: false),
            delegate: _Recording(lines),
          ),
        )
        ..v1('Boot | frame | painted')
        ..d('Control | state | AuthenticationController')
        ..i('Auth | signIn | ok')
        ..w('Rpc | call | failed')
        ..e('Zone | uncaught | error', error: StateError('boom'))
        ..f('Boot | step | failed');

      expect(lines.map((entry) => entry.level), LogLevel.values, reason: 'one line per level, in order');
      expect(lines.map((entry) => entry.line), everyElement(isNotEmpty));
    });

    test('renders one greppable line with its attributes inline', () {
      final lines = <({LogLevel level, String line})>[];
      Telemetry(runId: 'run-web')
        ..addSink(
          ConsoleSink(
            options: const TelemetryOptions(printColors: false, showTime: false),
            delegate: _Recording(lines),
          ),
        )
        ..i('Rpc | call | ok', meta: <String, Object?>{'rpc.path': '/auth.v1/SignIn'});

      expect(lines.single.line, '[I] Rpc | call | ok rpc.path=/auth.v1/SignIn');
    });

    test('the real browser delegate writes without throwing', () {
      // Exercises `delegate_js.dart` itself: the extension-type bindings over `window.console`
      // are `external`, so a wrong name is a runtime failure and nothing else catches it.
      final telemetry = Telemetry(runId: 'run-web')
        ..addSink(ConsoleSink(options: const TelemetryOptions(showTime: false)));

      expect(() {
        telemetry
          ..i('Web | console | info')
          ..w('Web | console | warn')
          ..e('Web | console | error', error: StateError('boom'));
      }, returnsNormally);
    });
  });
}

final class _Recording implements ConsoleDelegate {
  const _Recording(this.lines);
  final List<({LogLevel level, String line})> lines;

  @override
  void write(LogLevel level, String line) => lines.add((level: level, line: line));
}
