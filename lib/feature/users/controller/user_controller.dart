import 'package:auth_app/app/app.dart';
import 'package:auth_app/app/message/controller/app_message_controller_mixin.dart';
import 'package:auth_app/feature/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_controller.freezed.dart';

@freezed
class UserState with _$UserState {
  const factory UserState.idle() = _idleState;
  const factory UserState.created(User user) = UserCreateState;
  const factory UserState.updated(User user) = UserUpdateState;
}

final class UserController extends StateController<UserState>
    with DroppableControllerHandler, AppMessageControllerMixin {
  final IUsersRepository _repository;

  UserController({
    super.initialState = const UserState.idle(),
    required IUsersRepository repository,
    required AppMessageController messageController,
  }) : _repository = repository {
    this.messageController = messageController;
  }

  void createUser(User user, String password) => handle(
        () async {
          setProgress(AppProgress.started);

          // TODO: generate user blurhash
          final result = await _repository.createUser(user, password);
          result //
              ? setMessage('User successfully saved', Colors.green[700])
              : setError('Error on saving user');

          setState(UserState.created(user));
        },
        (error, stackTrace) {
          setError('Error on saving user', error, stackTrace);
          Error.throwWithStackTrace(error, stackTrace);
        },
        () {
          setProgress(AppProgress.done);
          setState(const UserState.idle());
        },
      );

  void updateUser(User user) => handle(
        () async {
          setProgress(AppProgress.started);

          // TODO: update user blurhash
          final result = await _repository.updateUser(user);
          result //
              ? setMessage('User successfully saved', Colors.green[700])
              : setError('Error on saving user');

          setState(UserState.updated(user));
        },
        (error, stackTrace) {
          setError('Error on saving user', error, stackTrace);
          Error.throwWithStackTrace(error, stackTrace);
        },
        () {
          setProgress(AppProgress.done);
          setState(const UserState.idle());
        },
      );
}
