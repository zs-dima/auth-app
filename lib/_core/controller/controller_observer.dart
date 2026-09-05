import 'package:auth_app/_core/log/telemetry.dart';
import 'package:control/control.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Watches every controller in the app and turns its life into telemetry.
///
/// Transitions are logged at [LogLevel.debug] with the controller, the handler
/// and the states as ATTRIBUTES rather than interpolated into the message: the
/// body stays one stable line per kind of transition, which is what makes it
/// greppable and groupable, while the values stay queryable.
class ControllerObserver with _SentryTransactionMixin implements IControllerObserver {
  /// Longest state rendering kept; beyond this the line stops being readable.
  static const int _maxStateLength = 200;

  /// The single observer instance, wired in the composition root.
  factory ControllerObserver.instance() => _instance ??= ControllerObserver._();

  ControllerObserver._() {
    log.v4('Control | observer | created');
  }

  static ControllerObserver? _instance;

  @override
  void onCreate(Controller controller) =>
      log.v6('Control | lifecycle | created', meta: <String, Object?>{'control.controller': controller.name});

  @override
  void onHandler(HandlerContext context) {
    final controller = context.controller;
    _startTransaction(controller, context);
    final stopwatch = Stopwatch()..start();
    log.d(
      'Control | handler | started',
      meta: <String, Object?>{
        'control.controller': controller.name,
        'control.handler': context.name,
      },
    );
    context.done.whenComplete(() {
      stopwatch.stop();
      log.d(
        'Control | handler | finished',
        meta: <String, Object?>{
          'control.controller': controller.name,
          'control.handler': context.name,
          'control.duration_ms': stopwatch.elapsedMilliseconds,
        },
      );
      _finishTransaction(controller, true);
    });
  }

  @override
  void onStateChanged<S extends Object>(StateController<S> controller, S prevState, S nextState) {
    final context = Controller.context;
    log.d(
      'Control | state | changed',
      meta: <String, Object?>{
        'control.controller': controller.name,
        if (context != null) 'control.handler': context.name,
        'control.from': _truncate(prevState),
        'control.to': _truncate(nextState),
      },
    );
    _setState(controller, nextState);
  }

  /// Whether this failure has an owner, i.e. whether the handler's own `error:` callback will
  /// report it.
  ///
  /// `control` has two error paths and only one of them runs `error:`. A throw from the body goes
  /// through `onError`, which calls the observer and THEN the callback, while the handler is still
  /// running. An error from an unawaited future inside the body goes through `handleZoneError`,
  /// which calls the observer and asserts — nothing else — so in a release build nobody reports it.
  ///
  /// The two are told apart by the only signal available from out here: the zone error arrives
  /// after the handler has completed, so its context is already done. Not perfect (a zone error
  /// raised while the handler is still running still reads as owned), and it costs nothing when it
  /// guesses wrong: the line is a level louder. The real fix is upstream —
  /// `docs/control-zone-error-issue.md`.
  static bool _isOwned(HandlerContext? context) => context != null && !context.isDone;

  @override
  void onError(Controller controller, Object error, StackTrace stackTrace) {
    final context = Controller.context;
    final owned = _isOwned(context);
    log(owned ? 'Control | handler | failed' : 'Control | handler | unowned failure')
        .cause(error, stackTrace)
        .meta(<String, Object?>{
          'control.controller': controller.name,
          if (context != null) ...<String, Object?>{
            'control.handler': context.name,
            for (final MapEntry(:key, :value) in context.meta.entries) 'control.meta.$key': value,
          },
        })
        // `debug` when the failure has an owner: the handler's `error:` callback reports it through
        // the pipeline (a contract test guarantees every handler has one), so this line is the
        // TRAIL beside it — carrying the `control.meta.*` the report does not. At `warn` both rows
        // became Sentry breadcrumbs: one failure, twice, in the ring where space is scarce.
        //
        // `warn` when it has none: an unawaited future that threw is a defect, and this line is the
        // only record of it.
        .at(owned ? LogLevel.debug : LogLevel.warn);
    _finishTransaction(controller, false, error, stackTrace);
  }

  @override
  void onDispose(Controller controller) {
    _finishTransaction(controller, true);
    log.v5('Control | lifecycle | disposed', meta: <String, Object?>{'control.controller': controller.name});
  }

  /// Truncates a state rendering that would otherwise dominate the line.
  static String _truncate(Object state) {
    final text = state.toString();
    if (text.length <= _maxStateLength) return text;
    // ignore: avoid-substring — a split surrogate would only shorten the label.
    return '${text.substring(0, _maxStateLength)}… (${text.length} chars)';
  }
}

mixin _SentryTransactionMixin {
  /// Sentry transactions, one per in-flight handler.
  final _transactions = <Controller, ISentrySpan>{};
  final _states = <Controller, List<String>>{};

  /// Longest state timeline attached to one span.
  static const int _maxStates = 20;

  void _startTransaction(Controller controller, HandlerContext context) {
    // Nothing to trace when Sentry is not running — debug builds, and the user's
    // opt-out. The observer is installed unconditionally; the GATE lives here.
    if (!Sentry.isEnabled) return;
    try {
      _finishTransaction(controller, true);
      _transactions[controller] =
          Sentry.startTransaction(
              controller.name,
              context.name,
              bindToScope: true,
              autoFinishAfter: const Duration(minutes: 5),
            )
            ..setTag('controller_type', controller.name)
            ..setData('event', context.name);
    } on Object catch (error, stackTrace) {
      log.w('Control | transaction | start failed', error: error, stackTrace: stackTrace);
    }
  }

  // Buffer only while a transaction is active — otherwise entries accumulate
  // for the controller's lifetime (the messenger emits outside handle()).
  void _setState<S extends Object>(StateController<S> controller, S state) {
    if (!_transactions.containsKey(controller)) return;
    // The TYPE, not the rendering. A trace wants the shape of the sequence
    // (`Idle -> Processing -> Error`), and a state's `toString()` carries its
    // payload — which on a transaction leaves the device.
    final states = _states[controller] ??= <String>[];
    // A chatty handler would otherwise write one `State #i` per transition onto a
    // single span; twenty is more than any handler needs to explain itself.
    if (states.length >= _maxStates) states.removeAt(0);
    states.add(state.runtimeType.toString());
  }

  void _finishTransaction(Controller controller, bool successful, [Object? error, StackTrace? stackTrace]) {
    // remove() in every branch: a lingering key pins the controller (and its
    // last state) forever.
    try {
      final transaction = _transactions[controller];
      if (transaction == null || transaction.finished) {
        _transactions.remove(controller);
        _states.remove(controller);
        return;
      }

      final states = _states[controller] ?? const <String>[];
      for (var i = 0; i < states.length; i++) {
        transaction.setData('State #$i', states[i]);
      }

      if (error != null) transaction.throwable = error;
      transaction.finish(status: successful ? const SpanStatus.ok() : const SpanStatus.internalError());

      _transactions.remove(controller);
      _states.remove(controller);
    } on Object catch (error, stackTrace) {
      log.w('Control | transaction | finish failed', error: error, stackTrace: stackTrace);
    }
  }
}
