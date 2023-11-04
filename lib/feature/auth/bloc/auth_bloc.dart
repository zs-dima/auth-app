import 'dart:async';

import 'package:auth_app/app/app.dart';
import 'package:auth_app/app/message/bloc/app_message_bloc_mixin.dart';
import 'package:auth_app/core/tool/device_info.dart';
import 'package:auth_app/feature/auth/data/auth_repository.dart';
import 'package:auth_app/feature/auth/data/model/sign_in_data.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_bloc.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.signIn(SignInData data) = _signInEvent;
  const factory AuthEvent.signOut() = _signOutEvent;
  const factory AuthEvent.updateUserInfo(IUserInfo user) = _updateUserInfoEvent;
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.idle({
    required AuthUser user,
    String? message,
    String? error,
  }) = AuthIdleState;

  const factory AuthState.processing({
    required AuthUser user,
    String? message,
  }) = _processingState;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> with AppMessageBlocMixin {
  final IAuthRepository _repository;
  StreamSubscription? _userSubscription;

  AuthBloc({
    required IAuthRepository repository,
    required AppMessageBloc messageBloc,
  })  : _repository = repository,
        super(const AuthState.idle(user: AuthUser.unauthenticated())) {
    this.messageBloc = messageBloc;
    _userSubscription = repository.authHandler
        .where((state) => state == AuthenticationState.unauthenticated)
        .listen((_) => add(const AuthEvent.signOut()));
    on(onEvents);
  }

  void onEvents(AuthEvent event, Emitter emit) => event.when(
        signIn: (SignInData data) async {
          try {
            emit(
              AuthState.processing(
                user: state.user,
                message: 'Logging in...',
              ),
            );
            final device = await DeviceInfo.instance(data.installationId);
            await _repository.signIn(data, device);
            if (!isClosed) emit(AuthState.idle(user: _repository.user));
          } on Object catch (error, s) {
            emitError(
              'Error on signing in',
              error,
              s,
              (message) {
                if (!isClosed) emit(AuthState.idle(user: state.user, error: message));
              },
            );
          }
        },
        signOut: () {
          try {
            emit(const AuthState.idle(user: AuthUser.unauthenticated()));
            _repository.signOut().ignore();
          } on Object catch (error, s) {
            emitError(
              'Error on signing out',
              error,
              s,
              (message) => emit(AuthState.idle(user: state.user, error: message)),
            );
          }
        },
        updateUserInfo: (IUserInfo user) async {
          final currentUser = state.user;
          if (currentUser is! AuthenticatedUser) return;
          if (currentUser.userInfo.id != user.id) return;

          await _repository.updateUserInfo(user);

          if (!isClosed) emit(AuthState.idle(user: _repository.user));
        },
      );

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
