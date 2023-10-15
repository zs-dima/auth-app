import 'package:auth_app/app/log/logger.dart';
import 'package:bloc/bloc.dart';
import 'package:core_tool/core_tool.dart';
import 'package:platform_info/platform_info.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppBlocObserver extends BlocObserver with _SentryTransactionMixin {
  static AppBlocObserver? _instance;
  factory AppBlocObserver.instance(Logger logger) => _instance ??= AppBlocObserver._(logger);
  AppBlocObserver._(Logger logger) {
    init(logger);
    _log.v5('AppBlocObserver Created');
  }

  @override
  void onCreate(BlocBase<Object?> bloc) {
    super.onCreate(bloc);
    _log.v4('BLoC Created [${bloc.runtimeType}]');
  }

  @override
  void onEvent(Bloc<Object?, Object?> bloc, Object? event) {
    super.onEvent(bloc, event);

    if (event == null) return;

    _startTransaction(bloc, event);

    final buffer = StringBuffer()
      ..write('BLoC ')
      ..write(bloc.runtimeType)
      ..write('.add(')
      ..write(event.runtimeType.typeName())
      ..write(') Event: ')
      ..writeln(event.toString().limit(100));

    _log.v5(buffer.toString());

    final state = bloc.state;
    if (state == null) return;
    _setState(bloc, state);
  }

  @override
  void onTransition(
    Bloc<Object?, Object?> bloc,
    Transition<Object?, Object?> transition,
  ) {
    super.onTransition(bloc, transition);

    final event = transition.event;
    final currentState = transition.currentState;
    final nextState = transition.nextState;
    if (event == null || currentState == null || nextState == null) return;

    _setState(bloc, nextState);

    final buffer = StringBuffer()
      ..write('BLoC ')
      ..write(bloc.runtimeType)
      ..write('.')
      ..write(bloc.runtimeType.typeName())
      ..write(': ')
      ..write(currentState.runtimeType.typeName())
      ..write('->')
      ..write(nextState.runtimeType.typeName())
      ..write('State: ')
      ..writeln(transition.nextState.toString().limit(100));

    _log.v6(buffer.toString());
  }

  @override
  void onError(
    BlocBase<Object?> bloc,
    Object error,
    StackTrace stackTrace,
  ) {
    super.onError(bloc, error, stackTrace);

    final buffer = StringBuffer()
      ..write('BLoC ')
      ..write(bloc.runtimeType)
      ..write(' | ')
      ..writeln(error);

    _log.e(buffer.toString(), stackTrace: stackTrace);

    _finishTransaction(bloc, false);
    if (platform.isIO) {
      // ErrorSound.instance.play();
    }
  }

  @override
  void onClose(BlocBase<Object?> bloc) {
    super.onClose(bloc);
    _finishTransaction(bloc, true);
    _log.v4('BLoC Closed [${bloc.runtimeType}]');
  }
}

mixin _SentryTransactionMixin {
  late Logger _log;

  // ignore: use_setters_to_change_properties
  void init(Logger log) => _log = log;

  /// Sentry transactions
  final Map<Closable, ISentrySpan?> _transactions = <Closable, ISentrySpan?>{};
  final Map<Closable, List<Object>?> _states = <Closable, List<Object>?>{};

  void _startTransaction(Closable bloc, Object event) {
    try {
      _finishTransaction(bloc, true);
      _transactions[bloc] = Sentry.startTransaction(
        bloc.runtimeType.toString(),
        'BLoC',
        autoFinishAfter: const Duration(milliseconds: 5 * 60 * 1000),
      )
        ..setTag(
          'bloc_type',
          bloc.runtimeType.toString(),
        )
        ..setTag(
          'event_type',
          event.runtimeType.typeName(),
        )
        ..setData(
          'Event',
          event.toString(),
        );
    } on Object catch (error, stackTrace) {
      _log.e('Error "$error" _SentryTransactionMixin._startTransaction', stackTrace: stackTrace);
    }
  }

  void _setState(BlocEventSink<Object?> bloc, Object state) => (_states[bloc] ??= <Object>[]).add(state);

  void _finishTransaction(Closable bloc, bool successful) {
    try {
      if (_transactions[bloc]?.finished ?? true) return;
      final states = _states[bloc] ?? <Object>[];
      var i = 0;
      for (final state in states) {
        _transactions[bloc]?.setData('State #$i', state.toString());
        i++;
      }
      states.clear();
      _transactions[bloc]?.finish(status: successful ? const SpanStatus.ok() : const SpanStatus.internalError());
      _transactions[bloc] = null;
      _states[bloc] = null;
    } on Object catch (error, stackTrace) {
      _log.e('Error "$error" _SentryTransactionMixin._finishTransaction', stackTrace: stackTrace);
    }
  }
}

extension BlocTypeX on Type {
  String typeName() => toString().replaceAll(r'_$_', '').replaceAll(r'_$', '');
}
