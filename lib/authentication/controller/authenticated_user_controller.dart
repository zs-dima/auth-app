import 'package:auth_app/_core/message/user_facing_error.dart';
import 'package:auth_app/users/controller/users_controller.dart';
import 'package:auth_model/auth_model.dart';
import 'package:control/control.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'authenticated_user_controller.freezed.dart';

@freezed
sealed class AuthenticatedUserState with _$AuthenticatedUserState {
  const factory AuthenticatedUserState.loading(IUserInfo user) = _loadingState;
  const factory AuthenticatedUserState.loaded(IUserInfo user) = AuthenticatedUserLoadedState;
}

final class AuthenticatedUserController extends StateController<AuthenticatedUserState>
    with SequentialControllerHandler {
  AuthenticatedUserController({
    required this._usersController,
    super.initialState = const AuthenticatedUserState.loading(UserInfo.empty),
  });

  final UsersController _usersController;

  void getUser(AuthUser user) => handle(
    () async {
      switch (user) {
        case final AuthenticatedUser authUser:
          if (state.user.id == authUser.userId) return;
          setState(const AuthenticatedUserState.loading(UserInfo.empty));

          await _usersController.reset();
          final userInfo = await _usersController.getUserInfo(authUser.userId);
          setState(AuthenticatedUserState.loaded(userInfo));
          break;

        default:
          if (identical(state.user, UserInfo.empty)) return;
          _usersController.reset().ignore();
          setState(const AuthenticatedUserState.loaded(UserInfo.empty));
      }
    },
    error: (error, stackTrace) async {
      reportFailure(
        'Users | current | load failed',
        error,
        stackTrace: stackTrace,
        caption: 'Error on loading current user',
      );
      setState(const AuthenticatedUserState.loaded(UserInfo.empty));
    },
    name: 'getUser',
  );
}
