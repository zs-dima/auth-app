import 'package:auth_app/app/app.dart';
import 'package:auth_app/app/message/bloc/app_message_bloc_mixin.dart';
import 'package:auth_app/feature/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_bloc.freezed.dart';

@freezed
class UserEvent with _$UserEvent {
  const factory UserEvent.createUser(User user, String password) = _createUserEvent;
  const factory UserEvent.updateUser(User user) = _updateUserEvent;
}

@freezed
class UserState with _$UserState {
  const factory UserState.idle() = _idleState;
  const factory UserState.created(User user) = UserCreateState;
  const factory UserState.updated(User user) = UserUpdateState;
}

class UserBloc extends Bloc<UserEvent, UserState> with AppMessageBlocMixin {
  final IUsersRepository _repository;

  UserBloc({
    required IUsersRepository repository,
    required AppMessageBloc messageBloc,
  })  : _repository = repository,
        super(const UserState.idle()) {
    this.messageBloc = messageBloc;
    on(onEvents);
  }

  void onEvents(UserEvent event, Emitter emit) => event.when(
        createUser: (User user, String password) async {
          emitProgress(AppProgress.startedEvent);
          try {
            // TODO: generate user blurhash
            final result = await _repository.createUser(user, password);
            result //
                ? emitMessage('User successfully saved', Colors.green[700])
                : emitError('Error on saving user');

            emit(UserState.created(user));
          } on Exception catch (e, s) {
            emitError('Error on saving user', e, s);
            Error.throwWithStackTrace(e, s);
          } finally {
            emitProgress(AppProgress.doneEvent);
            emit(const UserState.idle());
          }
        },
        updateUser: (User user) async {
          emitProgress(AppProgress.startedEvent);
          try {
            // TODO: update user blurhash
            final result = await _repository.updateUser(user);
            result //
                ? emitMessage('User successfully saved', Colors.green[700])
                : emitError('Error on saving user');

            emit(UserState.updated(user));
          } on Exception catch (e, s) {
            emitError('Error on saving user', e, s);
            Error.throwWithStackTrace(e, s);
          } finally {
            emitProgress(AppProgress.doneEvent);
            emit(const UserState.idle());
          }
        },
      );
}
