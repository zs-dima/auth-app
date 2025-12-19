import 'package:auth_app/app/log/logger.dart';
import 'package:control/control.dart';
import 'package:platform_info/platform_info.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ControllerObserver with _SentryTransactionMixin implements IControllerObserver {
  static ControllerObserver? _instance;
  factory ControllerObserver.instance(Logger logger) => _instance ??= ControllerObserver._(logger);
  ControllerObserver._(Logger logger) {
    init(logger);
    _log.v4('🪢 observer created');
  }

  @override
  void onCreate(Controller controller) {
    _log.v6('🪢 ${controller.runtimeType} | Created');
  }

  @override
  void onHandler(HandlerContext context) {
    _log.v6('🪢 ${context.controller.runtimeType}.${context.name} | Started');
  }

  @override
  void onDispose(Controller controller) {
    _finishTransaction(controller, true);
    _log.v5('🪢 ${controller.runtimeType} | Disposed');
  }

  @override
  void onStateChanged<S extends Object>(StateController<S> controller, S prevState, S nextState) {
    // _startTransaction(controller, event);
    _log.d('🪢 ${controller.runtimeType} | $prevState -> $nextState');
    _setState(controller, nextState);
  }

  @override
  void onError(Controller controller, Object error, StackTrace stackTrace) {
    _log.w('🪢 ${controller.runtimeType}', error: error, stackTrace: stackTrace);
    _finishTransaction(controller, false);
    if (platform.desktop) {
      // ErrorSound.instance.play();
    }
  }
}

mixin _SentryTransactionMixin {
  late Logger _log;

  // ignore: use_setters_to_change_properties
  void init(Logger log) => _log = log;

  /// Sentry transactions
  final _transactions = <Controller, ISentrySpan?>{};
  final _states = <Controller, List<Object>?>{};

  // void _startTransaction(Controller controller, Object event) {
  //   try {
  //     _finishTransaction(controller, true);
  //     _transactions[controller] = Sentry.startTransaction(
  //       controller.runtimeType.toString(),
  //       '🪢',
  //       autoFinishAfter: const Duration(milliseconds: 5 * 60 * 1000),
  //     )
  //       ..setTag(
  //         'controller_type',
  //         controller.runtimeType.toString(),
  //       )
  //       ..setTag(
  //         'event_type',
  //         event.runtimeType.typeName,
  //       )
  //       ..setData(
  //         'Event',
  //         event.toString(),
  //       );
  //   } on Object catch (error, stackTrace) {
  //     _log.e('Error "$error" _SentryTransactionMixin._startTransaction', stackTrace: stackTrace);
  //   }
  // }

  void _setState<S extends Object>(StateController<S> controller, S state) =>
      (_states[controller] ??= <Object>[]).add(state);

  void _finishTransaction(Controller controller, bool successful) {
    try {
      if (_transactions[controller]?.finished ?? true) return;
      final states = _states[controller] ?? <Object>[];
      var i = 0;
      for (final state in states) {
        _transactions[controller]?.setData('State #$i', state.toString());
        i++;
      }
      states.clear();
      _transactions[controller]?.finish(status: successful ? const SpanStatus.ok() : const SpanStatus.internalError());
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
