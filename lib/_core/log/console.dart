import 'package:flutter/foundation.dart';
import 'package:telemetry/telemetry.dart';

/// Console behaviour for this app.
///
/// Colours only where a terminal renders them; output kept in release because
/// the journal and the dev menu are not the only readers — a tester with a
/// device log is one too, and nothing here is secret (every type that holds
/// token or PII material redacts its own `toString`, refresh_token.md §13).
const TelemetryOptions kConsoleOptions = TelemetryOptions(
  printColors: kDebugMode,
  outputInRelease: true,
  handlePrint: true,
  // `trace` tiers are opt-in noise: raise this while chasing something.
  maxVerbosity: 4,
  // A release console is a device log — `adb logcat`, Console.app, a tester's bug
  // report. `info` there, `trace` in debug: the debug lines are state transitions
  // whose attributes carry whole state renderings, and a device log is the one
  // destination with no consent, no redaction and no expiry.
  minLevel: kReleaseMode ? .info : .trace,
  // The bare letter: the colour says the level, and the brackets were only
  // ever there for a log without it.
  levelTag: .letter,
  // One glyph per subsystem after the level tag, and the word for the area
  // dropped since the glyph says it. A CONSOLE choice only: the journal, Sentry
  // and the breadcrumb trail are given the body, which stays
  // `Area | operation | message`.
  icon: AreaIcons(<String, String>{
    'Auth': '🔑',
    'Users': '👥',
    'Avatar': '🖼',
    'Image': '🖼',
    'Control': '🪢',
    'Rpc': '🌍',
    'Http': '🌍',
    'Router': '🧭',
    'Database': '🗃',
    'Journal': '🗃',
    'Maintenance': '🧹',
    'Migrator': '📦',
    'Environment': '🌱',
    'Device': '📱',
    'Boot': '💫', // 🏗️ 🚀
    'App': '📱',
    'Sentry': '🛰',
    'Settings': '⚙️',
    'Logging': '🔌',
    'Flutter': '🧩',
    'Zone': '🧨',
    'Platform': '🧨',
    'Telemetry': '🔭',
  }),
);
