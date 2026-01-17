import 'package:auth_app/_core/message/controller/app_message_controller_mixin.dart';
import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_app/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_controller.freezed.dart';

@freezed
class UserState with _$UserState {
  const factory UserState.idle() = _idleState;
  const factory UserState.created(User user) = UserCreatedState;
  const factory UserState.updated(User user) = UserUpdatedState;
}

final class UserController extends StateController<UserState>
    with DroppableControllerHandler, AppMessageControllerMixin {
  UserController({
    super.initialState = const UserState.idle(),
    required IUsersRepository repository,
    required AppMessageController messageController,
  }) : _repository = repository {
    this.messageController = messageController;
  }

  final IUsersRepository _repository;

  void createUser(CreateUserData data) => handle(
    () async {
      setProgressStarted();

      final result = await _repository.createUser(data);
      result ==
              null //
          ? setError('Error on saving user')
          : setMessage('User successfully saved', Colors.green[700]);

      if (result != null) setState(UserState.created(result));
    },
    error: (error, stackTrace) async {
      setError('Error on saving user', error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    },
    done: () async {
      setProgressDone();
      setState(const UserState.idle());
    },
  );

  void updateUser(UpdateUserData data) => handle(
    () async {
      setProgressStarted();

      final result = await _repository.updateUser(data);
      result ==
              null //
          ? setError('Error on saving user')
          : setMessage('User successfully saved', Colors.green[700]);

      if (result != null) setState(UserState.updated(result));
    },
    error: (error, stackTrace) async {
      setError('Error on saving user', error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    },
    done: () async {
      setProgressDone();
      setState(const UserState.idle());
    },
  );
}
