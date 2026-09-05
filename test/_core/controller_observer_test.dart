import 'dart:async';

import 'package:auth_app/_core/controller/controller_observer.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:control/control.dart';
import 'package:flutter_test/flutter_test.dart';

/// Which controller failures the observer treats as already reported, and which it has to report
/// itself.
///
/// `control` has two error paths and only one runs the handler's `error:` callback. A body that
/// throws goes through `onError`, which calls the callback afterwards — the callback owns the
/// incident, so the observer's line is a trail and stays at `debug`. An unawaited future that
/// throws goes through `handleZoneError`, which notifies the observer, asserts, and stops: in a
/// release build (no asserts) nothing else records it, so the observer's line IS the record.
///
/// The signal telling them apart is `HandlerContext.isDone` — see `ControllerObserver._isOwned`
/// and `docs/control-zone-error-issue.md` for the upstream fix that would make it unnecessary.
void main() {
  late List<LogEvent> events;
  late _Recorder recorder;
  late ControllerObserver observer;

  setUp(() {
    events = <LogEvent>[];
    recorder = _Recorder(events);
    log.addSink(recorder);
    observer = ControllerObserver.instance();
    Controller.observer = observer;
  });

  tearDown(() {
    log.removeSink(recorder);
    Controller.observer = null;
  });

  LogEvent? lineFor(String body) => events.where((event) => event.body == body).firstOrNull;

  test('a body that throws is a debug trail: the handler error: callback reports it', () async {
    final controller = _Controller();
    addTearDown(controller.dispose);

    controller.failInBody();
    await pumpEventQueue();

    expect(controller.reported, isTrue, reason: 'this is the path that runs error:');
    final line = lineFor('Control | handler | failed');
    expect(line, isNotNull);
    expect(line!.level, equals(LogLevel.debug));
    expect(lineFor('Control | handler | unowned failure'), isNull);
  });

  test('a failure whose handler has already completed is a warning', () async {
    // What a zone error looks like from the observer's side: `control` notifies it AFTER the
    // handler finished, so the context is done and `error:` will not run. Driven through the zone
    // directly because the real path also trips `control`'s own `assert(false)`, which is the
    // debug half of the same defect (see the next test).
    final controller = _Controller();
    addTearDown(controller.dispose);

    runZoned(
      () => observer.onError(controller, StateError('from an unawaited future'), .current),
      zoneValues: <Object?, Object?>{HandlerContext.key: _DoneContext(controller)},
    );

    final line = lineFor('Control | handler | unowned failure');
    expect(line, isNotNull, reason: 'the observer is the only record left');
    expect(line!.level, equals(LogLevel.warn));
    expect(line.meta['control.handler'], equals('failInUnawaitedFuture'));
    expect(lineFor('Control | handler | failed'), isNull);
  });

  test('a real unawaited future reaches the observer with a completed handler', () async {
    // The premise of the test above, against the real `control`: the zone error arrives after the
    // handler is done, and `error:` never runs. `control` also asserts, which a release build does
    // not — hence the guard, and hence the warning being the only record there.
    final controller = _Controller();
    addTearDown(controller.dispose);

    final asserted = <Object>[];
    await runZonedGuarded(
      () async {
        controller.failInUnawaitedFuture();
        await pumpEventQueue();
      },
      (error, stackTrace) => asserted.add(error),
    );

    expect(controller.reported, isFalse, reason: 'control does not run error: for a zone error');
    expect(asserted.single, isA<AssertionError>(), reason: "control's debug-only assert");
    final line = lineFor('Control | handler | unowned failure');
    expect(line, isNotNull);
    expect(line!.level, equals(LogLevel.warn));
  });
}

final class _Controller extends StateController<int> with SequentialControllerHandler {
  _Controller() : super(initialState: 0);

  /// Whether the handler's own `error:` callback ran.
  bool reported = false;

  void failInBody() => handle(
    () async => throw StateError('from the body'),
    error: (error, stackTrace) async => reported = true,
    name: 'failInBody',
  );

  void failInUnawaitedFuture() => handle(
    () async {
      // The defect the warning exists for: a future created and not awaited.
      unawaited(Future<void>.error(StateError('from an unawaited future')));
      await Future<void>.delayed(.zero);
    },
    error: (error, stackTrace) async => reported = true,
    name: 'failInUnawaitedFuture',
  );
}

/// A handler context that has already completed — what a zone error carries.
final class _DoneContext implements HandlerContext {
  const _DoneContext(this.controller);

  @override
  final Controller controller;

  @override
  String get name => 'failInUnawaitedFuture';

  @override
  Future<void> get done => Future<void>.value();

  @override
  bool get isDone => true;

  @override
  Map<String, Object?> get meta => const <String, Object?>{};
}

final class _Recorder implements TelemetrySink {
  const _Recorder(this.events);

  final List<LogEvent> events;

  @override
  bool enabled(LogLevel level, int verbosity) => true;

  @override
  void handle(LogEvent event) => events.add(event);
}
