import 'dart:async';

import 'package:auth_app/_core/message/controller/app_message_controller_mixin.dart';
import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_app/_core/tool/device_info.dart';
import 'package:auth_app/authentication/controller/authentication_state.dart';
import 'package:auth_app/authentication/data/auth_repository.dart';
import 'package:auth_app/authentication/data/model/sign_in_data.dart';
import 'package:auth_model/auth_model.dart' show AuthUser, AuthenticatedUser, IUserInfo;
import 'package:control/control.dart';

final class AuthenticationController extends StateController<AuthenticationState>
    with DroppableControllerHandler, AppMessageControllerMixin {
  AuthenticationController({
    super.initialState = const AuthenticationState.idle(user: AuthUser.unauthenticated()),
    required IAuthRepository repository,
    required AppMessageController messageController,
  }) : _repository = repository {
    this.messageController = messageController;

    _userSubscription = repository.userChanges
        .map<AuthenticationState>((u) => AuthenticationState.idle(user: u))
        .where((newState) => state.isProcessing || !identical(newState.user, state.user))
        .listen(setState, cancelOnError: false);
  }
  final IAuthRepository _repository;

  StreamSubscription<AuthenticationState>? _userSubscription;

  /// Restore the session from the cache.
  // void restore() => handle(
  //       () async {
  //         setState(
  //           AuthenticationState.processing(
  //             user: state.user,
  //             message: 'Restoring session...',
  //           ),
  //         );
  //         await _repository.restore();
  //       },
  //       (error, _) => setState(
  //         const AuthenticationState.idle(
  //           user: AuthUser.unauthenticated(),
  //           error: 'Restore Error', // ErrorUtil.formatMessage(error)
  //         ),
  //       ),
  //       () => setState(
  //         AuthenticationState.idle(user: state.user),
  //       ),
  //     );

  /// Sign in with the given [data].
  void signIn(SignInData data) => handle(
    () async {
      setState(AuthenticationState.processing(user: state.user, message: 'Logging in...'));
      final device = await DeviceInfo.instance(data.installationId);
      await _repository.signIn(data, device);
    },
    error: (error, stackTrace) async {
      setError('Signin error', error, stackTrace);
      setState(AuthenticationState.idle(user: state.user, error: 'Signin error'));
    },
    done: () async => setState(AuthenticationState.idle(user: _repository.user)),
  );

  /// Sign out.
  void signOut() => handle(
    () async {
      setState(AuthenticationState.processing(user: state.user, message: 'Logging out...'));
      await _repository.signOut();
    },
    error: (error, stackTrace) async {
      setError('Logout error', error, stackTrace);
      setState(
        AuthenticationState.idle(
          user: state.user,
          error: 'Logout error', // TODO ErrorUtil.formatMessage(error)
        ),
      );
    },
    done: () async => setState(const AuthenticationState.idle(user: AuthUser.unauthenticated())),
  );

  /// Update UserInfo.
  void updateUserInfo(IUserInfo user) => handle(
    () async {
      final currentUser = state.user;
      if (currentUser is! AuthenticatedUser) return;
      if (currentUser.userInfo.id != user.id) return;

      setState(AuthenticationState.processing(user: state.user, message: 'Updating user information...'));

      await _repository.updateUserInfo(user);
    },
    error: (error, stackTrace) async {
      setError('Updating user error', error, stackTrace);
      setState(AuthenticationState.idle(user: state.user, error: 'Updating user information error'));
    },
    done: () async => setState(AuthenticationState.idle(user: _repository.user)),
  );

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
