import 'dart:async';

import 'package:auth_app/_core/log/telemetry.dart';

/// Silences the telemetry console for the whole suite.
///
/// Almost every test here drives a controller or a deliberately failing
/// repository, and the pipeline's console sink faithfully writes all of it: the
/// real output of `flutter test` was hundreds of lines of correctly-working
/// error handling with the actual failures buried inside them.
///
/// Removing the SINK rather than installing quiet `TelemetryOptions`, because
/// `package:test` runs every test body in a zone forked from the suite root
/// rather than from here — a zone installed around `testMain()` covers
/// declaration and nothing else. Everything else about the pipeline stays live,
/// so a test can still subscribe to `log.events` or attach a sink of its own.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // `--dart-define=TELEMETRY_CONSOLE=true` keeps it, so chasing one flaky test
  // does not mean editing the file every other test shares.
  if (!const bool.fromEnvironment('TELEMETRY_CONSOLE')) log.removeSink(consoleSink);
  await testMain();
}
