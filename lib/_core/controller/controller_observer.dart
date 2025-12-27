import 'package:auth_app/_core/log/logger.dart';
import 'package:control/control.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ControllerObserver with _SentryTransactionMixin implements IControllerObserver {
  factory ControllerObserver.instance(Logger logger) => _instance ??= ControllerObserver._(logger);
  ControllerObserver._(Logger logger) {
    init(logger);
    _log.v4('🪢 observer created');
  }

  static ControllerObserver? _instance;

  @override
  void onCreate(Controller controller) {
    _log.v6('🪢 ${controller.name} | Created');
  }

  @override
  void onHandler(HandlerContext context) {
    final controller = context.controller;
    _startTransaction(controller, context);
    final stopwatch = Stopwatch()..start();
    _log.d('🪢 ${controller.name} ${context.name}' /*context.meta*/);
    context.done.whenComplete(() {
      stopwatch.stop();
      _log.d('🪢 ${controller.name} ${context.name} | duration: ${stopwatch.elapsed}' /*context.meta*/);
      _finishTransaction(controller, true);
    });
  }

  @override
  void onStateChanged<S extends Object>(StateController<S> controller, S prevState, S nextState) {
    final context = Controller.context;
    if (context == null) {
      // State change occurred outside of the handler
      _log.d(
        '🪢 ${controller.name} | '
        '$prevState -> $nextState',
      );
    } else {
      // State change occurred inside the handler
      _log.d(
        '🪢 ${controller.name}.${context.name} | '
        '$prevState -> $nextState',
        // context.meta,
      );
    }
    _setState(controller, nextState);
  }

  @override
  void onError(Controller controller, Object error, StackTrace stackTrace) {
    final context = Controller.context;
    if (context == null) {
      // Error occurred outside of the handler
      _log.w('🪢 ${controller.name} | $error', error: error, stackTrace: stackTrace);
    } else {
      // Error occurred inside the handler
      _log.w(
        '🪢 ${controller.name}.${context.name} | $error',
        error: error,
        stackTrace: stackTrace,
        data: context.meta,
      );
    }
    _finishTransaction(controller, false, error, stackTrace);
  }

  @override
  void onDispose(Controller controller) {
    _finishTransaction(controller, true);
    _log.v5('🪢 ${controller.name} | Disposed');
  }
}

mixin _SentryTransactionMixin {
  late Logger _log;

  // ignore: use_setters_to_change_properties
  void init(Logger log) => _log = log;

  /// Sentry transactions
  final _transactions = <Controller, ISentrySpan?>{};
  final _states = <Controller, List<Object>?>{};

  void _startTransaction(Controller controller, HandlerContext context) {
    try {
      _finishTransaction(controller, true);
      _transactions[controller] =
          Sentry.startTransaction(
              controller.name,
              context.name,
              bindToScope: true,
              autoFinishAfter: const Duration(milliseconds: 5 * 60 * 1000),
            )
            ..setTag('controller_type', controller.name)
            ..setTag('meta', context.meta.toString())
            ..setData('event', context.name);
    } on Object catch (error, stackTrace) {
      _log.e('Error "$error" _SentryTransactionMixin._startTransaction', stackTrace: stackTrace);
    }
  }

  void _setState<S extends Object>(StateController<S> controller, S state) =>
      (_states[controller] ??= <Object>[]).add(state);

  void _finishTransaction(Controller controller, bool successful, [Object? error, StackTrace? stackTrace]) {
    try {
      final transaction = _transactions[controller];
      if (transaction == null || transaction.finished) return;

      final states = _states[controller] ?? <Object>[];
      var i = 0;
      for (final state in states) {
        transaction.setData('State #$i', state.toString());
        i++;
      }
      states.clear();

      if (error != null) transaction.throwable = error;
      transaction.finish(status: successful ? const SpanStatus.ok() : const SpanStatus.internalError());

      _transactions[controller] = null;
      _states[controller] = null;
    } on Object catch (error, stackTrace) {
      _log.e('Error "$error" _SentryTransactionMixin._finishTransaction', stackTrace: stackTrace);
    }
  }
}

extension _TypeX on Type {
  String get typeName => toString().replaceAll(r'_$_', '').replaceAll(r'_$', '');
}
