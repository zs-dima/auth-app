import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bus, and the two things about it that are easy to get wrong.
///
/// It drops a message nobody is listening for — correct for a toast with no screen to show it on
/// — with ONE carve-out: "no screen yet" is not "no screen any more". A message raised by a route
/// guard during startup used to vanish because the scope had not subscribed yet, which is how the
/// one message that flow exists to deliver was never seen. And the progress counter is a count,
/// not a flag: unbalanced by an early return or a throw it wedges the bar on for the rest of the
/// launch, which is why [UiMessenger.track] exists at all. Its listeners are notified a
/// microtask late, because the overlay watching it sits above the whole app and the loads that
/// move it start from widgets that are still mounting.
///
/// This file is copied between the apps with `ui_messenger.dart` itself.
void main() {
  late UiMessenger messenger;

  setUp(() => messenger = UiMessenger());
  tearDown(() => messenger.dispose());

  UiMessage message(String text) => UiMessage(tone: .info, text: text);

  group('held until the first subscriber', () {
    test('a message raised before anyone listens arrives on the first listen', () async {
      messenger.show(message('your e-mail is verified'));

      final seen = <String>[];
      messenger.messages.listen((m) => seen.add(m.text));
      await pumpEventQueue();

      expect(seen, <String>['your e-mail is verified']);
    });

    test('what is held is capped, oldest first', () async {
      for (var i = 0; i < 12; i++) {
        messenger.show(message('m$i'));
      }

      final seen = <String>[];
      messenger.messages.listen((m) => seen.add(m.text));
      await pumpEventQueue();

      expect(seen, hasLength(8), reason: 'this is the boot\'s own output, not a queue');
      expect(seen.first, 'm4', reason: 'the newest eight, so the last thing that happened is kept');
      expect(seen.last, 'm11');
    });

    test('after a subscriber has existed, a message raised in a gap is dropped', () async {
      final first = messenger.messages.listen((_) {});
      await pumpEventQueue();
      await first.cancel();

      messenger.show(message('nobody is looking'));

      final seen = <String>[];
      messenger.messages.listen((m) => seen.add(m.text));
      await pumpEventQueue();

      expect(seen, isEmpty, reason: 'the carve-out is for "not yet", never for "not any more"');
    });
  });

  group('progress', () {
    test('counts, so two operations are one bar and the first to finish does not take it', () {
      expect(messenger.progress.value, isZero);

      messenger
        ..progressStarted()
        ..progressStarted();
      expect(messenger.progress.value, 2);

      messenger.progressDone();
      expect(messenger.progress.value, 1, reason: 'the second operation still has the bar');

      messenger.progressDone();
      expect(messenger.progress.value, isZero);
    });

    test('never goes below zero', () {
      messenger
        ..progressDone()
        ..progressDone();

      expect(messenger.progress.value, isZero, reason: 'a negative count wedges the bar OFF');
    });

    test('track lowers it on a throw, and lets the failure through', () async {
      await expectLater(
        messenger.track<void>(() async => throw StateError('the store did not answer')),
        throwsStateError,
      );

      expect(messenger.progress.value, isZero);
    });

    test('track lowers it on an early return', () async {
      final answer = await messenger.track<int>(() async => 7);

      expect(answer, 7);
      expect(messenger.progress.value, isZero);
    });

    test('the value is synchronous, the notification is not', () async {
      final seen = <int>[];
      messenger.progress.addListener(() => seen.add(messenger.progress.value));

      messenger.progressStarted();

      expect(messenger.progress.value, 1, reason: 'a caller reads back what it just wrote');
      expect(
        seen,
        isEmpty,
        reason: 'a load started from a widget mount must not mark the overlay dirty mid-build',
      );

      await pumpEventQueue();
      expect(seen, <int>[1]);
    });

    test('a start and a finish inside one turn notify nobody', () async {
      var notifications = 0;
      messenger.progress.addListener(() => notifications++);

      messenger
        ..progressStarted()
        ..progressDone();
      await pumpEventQueue();

      expect(notifications, isZero, reason: 'the bar cannot flicker on an operation that never yielded');
      expect(messenger.progress.value, isZero);
    });

    test('resetProgress is the boundary net', () {
      messenger
        ..progressStarted()
        ..progressStarted()
        ..resetProgress();

      expect(messenger.progress.value, isZero);
    });
  });

  test('after dispose the counter is a no-op rather than a throw', () async {
    await messenger.dispose();

    // An upload still in flight when the engine detaches calls this, and nobody is waiting for
    // it: a `ValueNotifier` that throws after disposal would take the teardown with it.
    expect(
      () => messenger
        ..progressStarted()
        ..progressDone()
        ..resetProgress(),
      returnsNormally,
    );
    expect(() => messenger.show(message('too late')), returnsNormally);
  });
}
