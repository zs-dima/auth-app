import 'package:auth_model/auth_model.dart';
import 'package:meta/meta.dart';

/// {@template authentication_state}
/// AuthenticationState.
/// {@endtemplate}
sealed class AuthenticationState extends _$AuthenticationStateBase {
  /// {@macro authentication_state}
  const AuthenticationState({required super.user, required super.message});

  /// Idling state
  /// {@macro authentication_state}
  const factory AuthenticationState.idle({
    required AuthUser user,
    String message,
    String? error,
  }) = AuthenticationState$Idle;

  /// Processing
  /// {@macro authentication_state}
  const factory AuthenticationState.processing({
    required AuthUser user,
    String message,
  }) = AuthenticationState$Processing;
}

/// Idling state
/// {@nodoc}
final class AuthenticationState$Idle extends AuthenticationState with _$AuthenticationState {
  @override
  final String? error;

  /// {@nodoc}
  const AuthenticationState$Idle({
    required super.user,
    super.message = 'Idling',
    this.error,
  });
}

/// Processing
/// {@nodoc}
final class AuthenticationState$Processing extends AuthenticationState with _$AuthenticationState {
  @override
  String? get error => null;

  /// {@nodoc}
  const AuthenticationState$Processing({
    required super.user,
    super.message = 'Processing',
  });
}

/// {@nodoc}
base mixin _$AuthenticationState on AuthenticationState {}

/// Pattern matching for [AuthenticationState].
typedef AuthenticationStateMatch<R, S extends AuthenticationState> = R Function(
  S state,
);

/// {@nodoc}
@immutable
abstract base class _$AuthenticationStateBase {
  /// Data entity payload.
  @nonVirtual
  final AuthUser user;

  /// Message or state description.
  @nonVirtual
  final String message;

  /// Error message.
  abstract final String? error;

  /// If an error has occurred?
  bool get hasError => error != null;

  /// Is in progress state?
  bool get isProcessing => maybeMap<bool>(orElse: () => false, processing: (_) => true);

  /// Is in idle state?
  bool get isIdling => !isProcessing;

  @override
  int get hashCode => user.hashCode;

  /// {@nodoc}
  const _$AuthenticationStateBase({required this.user, required this.message});

  /// Pattern matching for [AuthenticationState].
  R map<R>({
    required AuthenticationStateMatch<R, AuthenticationState$Idle> idle,
    required AuthenticationStateMatch<R, AuthenticationState$Processing> processing,
  }) =>
      switch (this) {
        final AuthenticationState$Idle s => idle(s),
        final AuthenticationState$Processing s => processing(s),
        _ => throw AssertionError(),
      };

  /// Pattern matching for [AuthenticationState].
  R maybeMap<R>({
    required R Function() orElse,
    AuthenticationStateMatch<R, AuthenticationState$Idle>? idle,
    AuthenticationStateMatch<R, AuthenticationState$Processing>? processing,
  }) =>
      map<R>(
        idle: idle ?? (_) => orElse(),
        processing: processing ?? (_) => orElse(),
      );

  /// Pattern matching for [AuthenticationState].
  R? mapOrNull<R>({
    AuthenticationStateMatch<R, AuthenticationState$Idle>? idle,
    AuthenticationStateMatch<R, AuthenticationState$Processing>? processing,
  }) =>
      map<R?>(
        idle: idle ?? (_) => null,
        processing: processing ?? (_) => null,
      );

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write('AuthenticationState{')
      ..write('user: $user, ');
    if (error != null) buffer.write('error: $error, ');
    buffer
      ..write('message: $message')
      ..write('}');
    return buffer.toString();
  }
}
