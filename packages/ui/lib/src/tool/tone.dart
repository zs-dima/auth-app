import 'package:flutter/material.dart';

/// Semantic tone of a user-facing message.
///
/// Colour is never the only signal: every tone carries an icon too, so the
/// meaning survives a colour-blind reader and a monochrome screenshot.
///
/// This is the widget-layer twin of the telemetry package's `ToastTone`, which
/// carries the same three values without importing Flutter — a controller names
/// a tone, and only this file knows what it looks like.
enum AppTone {
  /// Neutral information.
  info,

  /// Something succeeded.
  ok,

  /// Something failed or needs attention.
  alert;

  /// Surface colour for this tone.
  Color background(ColorScheme scheme) => switch (this) {
    info => scheme.inverseSurface,
    ok => scheme.tertiary,
    alert => scheme.error,
  };

  /// Text and icon colour to use on [background].
  Color foreground(ColorScheme scheme) => switch (this) {
    info => scheme.onInverseSurface,
    ok => scheme.onTertiary,
    alert => scheme.onError,
  };

  /// The icon that carries the meaning when colour cannot.
  IconData get icon => switch (this) {
    info => Icons.info_outline,
    ok => Icons.check_circle_outline,
    alert => Icons.warning_amber_rounded,
  };
}
