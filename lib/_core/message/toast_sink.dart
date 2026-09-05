import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:telemetry/telemetry.dart';

/// {@template ui_messenger_toast_sink}
/// Delivers a telemetry event's user-facing text to the app's messenger.
///
/// The adapter exists so the pipeline stays pure Dart: a controller names a tone
/// and a localized sentence, and only this file knows that "showing" it means
/// putting a [UiMessage] on the [UiMessenger].
/// {@endtemplate}
final class UiMessengerToastSink implements ToastSink {
  /// {@macro ui_messenger_toast_sink}
  const UiMessengerToastSink(this.messenger);

  /// The bus this sink writes to.
  ///
  /// Public so a teardown can ask "is the sink still mine?" before clearing the
  /// slot: an abandoned composition disposing after a retry would otherwise
  /// silence the live app.
  final UiMessenger messenger;

  @override
  void toast(ToastRequest request) =>
      messenger.show(UiMessage(tone: request.tone, text: request.text, details: request.event));
}
