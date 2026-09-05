import 'dart:async';

import 'package:auth_app/_core/log/telemetry.dart';
import 'package:flutter/foundation.dart';

/// {@template ui_message}
/// One message meant for the user.
/// {@endtemplate}
@immutable
final class UiMessage {
  /// {@macro ui_message}
  const UiMessage({required this.tone, required this.text, this.details});

  /// How to present it — the widget layer maps the tone to the palette.
  final ToastTone tone;

  /// The LOCALIZED sentence the user reads.
  final String text;

  /// The event behind it: cause, stack and attributes, for the "Details" action
  /// outside production. Absent for a message nobody logged.
  final LogEvent? details;
}

/// {@template ui_messenger}
/// The app's user-message surface: toasts out, progress counted.
///
/// A message is an EVENT, not a state. The controller this replaced was a
/// `StateController` whose "state" was the last message, which meant a repeat of
/// the same failure could be swallowed as a no-change and a widget mounting late
/// re-rendered a toast the user had already dismissed. A broadcast stream has
/// neither problem, and it drops messages when nothing is listening — which is
/// the correct behaviour for a toast with no screen to show it on.
///
/// With one carve-out: "no screen YET" is not "no screen any more". The message
/// scope subscribes inside `MaterialApp.builder`, a build after the router's
/// guards run, so a message raised by a guard — the "your e-mail is verified,
/// please sign in" of a deep link, the one message that flow exists to deliver —
/// reached an empty stream and vanished. Messages raised before anyone has EVER
/// listened wait ([_kHoldLimit], [_kHoldWindow]) and arrive on the first
/// subscription; once a subscriber has existed, a gap drops as before.
///
/// Progress is the other half: a REFERENCE COUNT, not a pair of events, so two
/// overlapping operations show one overlay and the second's completion does not
/// hide it. The overlay watches [progress] and shows itself while it is
/// positive; [track] is how a call site keeps that count honest. Its listeners
/// are notified a microtask late — see [_ProgressCounter] for why.
/// {@endtemplate}
final class UiMessenger {
  /// {@macro ui_messenger}
  UiMessenger() {
    _messages.onListen = _replayHeld;
  }

  /// How many messages wait for the first subscriber. A handful: this is the
  /// boot's own output, not a queue.
  static const int _kHoldLimit = 8;

  /// How long a held message stays worth showing. Longer than a boot, shorter
  /// than a user's attention span.
  static const Duration _kHoldWindow = Duration(seconds: 10);

  final StreamController<UiMessage> _messages = StreamController<UiMessage>.broadcast();

  final List<({UiMessage message, DateTime at})> _held = <({UiMessage message, DateTime at})>[];
  bool _everListened = false;

  /// Messages as they are raised.
  ///
  /// The FIRST subscriber also receives whatever was raised before it existed
  /// (see the class doc); every later one sees only new messages.
  Stream<UiMessage> get messages => _messages.stream;

  final _ProgressCounter _progress = _ProgressCounter();

  bool _disposed = false;

  /// How many operations are currently in flight.
  ValueListenable<int> get progress => _progress;

  /// Raises [message].
  void show(UiMessage message) {
    if (_messages.isClosed) return;
    if (!_everListened && !_messages.hasListener) {
      if (_held.length >= _kHoldLimit) _held.removeAt(0);
      _held.add((message: message, at: DateTime.now()));
      return;
    }
    _messages.add(message);
  }

  /// Hands the first subscriber what was raised before it existed.
  void _replayHeld() {
    _everListened = true;
    if (_held.isEmpty) return;
    final fresh = DateTime.now().subtract(_kHoldWindow);
    final held = _held.where((entry) => entry.at.isAfter(fresh)).toList(growable: false);
    _held.clear();
    // A microtask, not inline: `onListen` runs while the subscription is being
    // set up, and adding to the controller from inside it delivers to nobody.
    scheduleMicrotask(() {
      for (final entry in held) {
        if (_messages.isClosed) return;
        _messages.add(entry.message);
      }
    });
  }

  /// Raises a neutral or successful message.
  void info(String text, {ToastTone tone = .info}) => show(UiMessage(tone: tone, text: text));

  /// Raises a failure the user should see.
  void error(String text) => show(UiMessage(tone: .alert, text: text));

  /// Runs [operation] with the progress bar up, whatever it does.
  ///
  /// The pair below is easy to unbalance — an early return, a throw, a scope torn
  /// down mid-flight — and an unbalanced `progressStarted` wedges the bar on for
  /// the rest of the launch. `try/finally` makes the invariant unbreakable
  /// instead of documented, which is why [resetProgress] exists at all.
  Future<T> track<T>(Future<T> Function() operation) async {
    progressStarted();
    try {
      return await operation();
    } finally {
      progressDone();
    }
  }

  /// Marks one operation started.
  ///
  /// A no-op after [dispose]. The counter is a notifier, which throws
  /// when touched after disposal, and the calls that reach here at shutdown are
  /// exactly the ones nobody is waiting for: an upload still in flight when the
  /// engine detaches.
  void progressStarted() {
    if (_disposed) return;
    _progress.value++;
  }

  /// Marks one operation finished. Never goes below zero — an unbalanced call
  /// must not make the counter negative and wedge the overlay off.
  void progressDone() {
    if (_disposed) return;
    if (_progress.value > 0) _progress.value--;
  }

  /// Drains the counter unconditionally.
  ///
  /// A safety net for boundaries where "no progress is in flight" is an
  /// invariant (sign-out, say), not a substitute for paired calls — [track] is.
  void resetProgress() {
    if (_disposed) return;
    _progress.value = 0;
  }

  /// Closes the bus.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _held.clear();
    _progress.dispose();
    await _messages.close();
  }
}

/// The in-flight count behind [UiMessenger.progress].
///
/// A `ValueNotifier` in all but one respect: the notification is DEFERRED to a
/// microtask. A load is routinely started from a widget's mount — a scope's
/// `didChangeDependencies` kicking off the screen's first request — and the
/// overlay that watches this count sits ABOVE the whole app, so notifying
/// synchronously there marks an already-built ancestor dirty in the middle of a
/// build: `setState() or markNeedsBuild() called during build`. A microtask
/// scheduled inside a frame runs once that frame is over, when marking a widget
/// dirty is legal again.
///
/// The VALUE moves synchronously, so a caller still reads back what it wrote,
/// and a start/finish pair inside one turn notifies nobody — the bar cannot
/// flicker on an operation that never yielded.
final class _ProgressCounter extends ChangeNotifier implements ValueListenable<int> {
  int _value = 0;
  int _notified = 0;
  bool _scheduled = false;
  bool _disposed = false;

  @override
  int get value => _value;

  set value(int next) {
    if (next == _value) return;
    _value = next;
    if (_scheduled || _disposed) return;
    _scheduled = true;
    scheduleMicrotask(() {
      _scheduled = false;
      if (_disposed || _value == _notified) return;
      _notified = _value;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
