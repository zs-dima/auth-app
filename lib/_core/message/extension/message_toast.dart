import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:auth_app/_core/message/widget/message_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart' show AppTone;

/// The widget-layer twin of the pipeline's tone.
AppTone _tone(ToastTone tone) => switch (tone) {
  .info => .info,
  .ok => .ok,
  .alert => .alert,
};

extension BuildContextX on BuildContext {
  /// Shows [message] as a snack bar.
  ///
  /// [withDetails] adds a Details action carrying the event behind the message —
  /// the caller decides, because in production the user must never be shown a
  /// stack trace.
  void showUiMessage(UiMessage message, {bool withDetails = false}) {
    final scheme = Theme.of(this).colorScheme;
    final tone = _tone(message.tone);
    final foreground = tone.foreground(scheme);
    final event = message.details;
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        backgroundColor: tone.background(scheme),
        duration: const Duration(seconds: 4),
        content: Row(
          spacing: 12,
          children: <Widget>[
            // The icon is inside the content, in the FOREGROUND colour: it used to be painted in
            // `colorScheme.error` on an `error` background, which is the same colour — an invisible
            // warning sign on every error toast.
            Icon(tone.icon, color: foreground),
            Expanded(
              child: Text(message.text, style: TextStyle(color: foreground)),
            ),
          ],
        ),
        action: withDetails && event != null
            ? SnackBarAction(
                label: 'Details',
                textColor: foreground,
                onPressed: () => MessageDetailsDialog.show(this, event),
              )
            : null,
      ),
    );
  }

  /// Shows a failure the user should see.
  void showError(String message, {LogEvent? details, bool withDetails = false}) => showUiMessage(
    UiMessage(tone: .alert, text: message, details: details),
    withDetails: withDetails,
  );
}
