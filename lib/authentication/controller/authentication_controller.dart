import 'dart:async';

import 'package:auth_app/_core/message/controller/app_message_controller_mixin.dart';
import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_app/authentication/controller/authentication_state.dart';
import 'package:auth_app/authentication/data/authentication_repository.dart';
import 'package:auth_model/auth_model.dart' hide AuthenticationState;
import 'package:control/control.dart';
import 'package:flutter/foundation.dart';

final class AuthenticationController extends StateController<AuthenticationState>
    with SequentialControllerHandler, AppMessageControllerMixin {
  AuthenticationController({
    required IAuthenticationRepository repository,
    required AppMessageController messageController,
    super.initialState = const AuthenticationState.idle(user: AuthUser.unauthenticated()),
  }) : _repository = repository {
    this.messageController = messageController;
    _userSubscription = repository.userChanges
        .where((user) => !identical(user, state.user))
        .map<AuthenticationState>((u) => AuthenticationState.idle(user: u))
        .listen(setState, cancelOnError: false);
  }

  final IAuthenticationRepository _repository;
  StreamSubscription<AuthenticationState>? _userSubscription;

  /// Restore the session from the cache.
  void restore() => handle(
    () async {
      setState(AuthenticationState.processing(user: state.user, message: 'Restoring session...'));
      final user = await _repository.restore();
      setState(AuthenticationState.idle(user: user));
    },
    error: (error, _) async {
      setState(
        AuthenticationState.idle(
          user: state.user,
          // ErrorUtil.formatMessage(error)
          error: kDebugMode ? 'Restore Error: $error' : 'Restore Error',
        ),
      );
    },
    name: 'restore',
  );

  /// Sign in with the given [data].
  void signIn(SignInData data) => handle(
    () async {
      setProgressStarted();
      if (state.user.isAuthenticated) {
        setState(AuthenticationState.processing(user: state.user, message: 'Logging out...'));
        await _repository.signOut().onError((_, __) {
          /* Ignore */
        });
        setState(
          const AuthenticationState.processing(user: AuthUser.unauthenticated(), message: 'Successfully logged out.'),
        );
      }
      setState(AuthenticationState.processing(user: state.user, message: 'Logging in...'));

      final user = await _repository.signIn(data);
      setState(AuthenticationState.idle(user: user, message: 'Successfully logged in.'));
    },
    error: (error, _) async {
      setError(kDebugMode ? 'Sign In Error, please check your credentials and try again./n$error' : 'Sign In Error');
      // setError('Sign In Error, please check your credentials and try again.');
      setState(
        AuthenticationState.idle(
          user: state.user,
          // ErrorUtil.formatMessage(error)
          error: kDebugMode ? 'Sign In Error: $error' : 'Sign In Error',
        ),
      );
    },
    done: () async => setProgressDone(),
    name: 'signIn',
  );

  /// Sign out.
  void signOut() {
    handle(
      () async {
        //if (state.user.isNotAuthenticated) return; // Already signed out.
        setState(AuthenticationState.processing(user: state.user, message: 'Logging out...'));

        await _repository.signOut();

        setState(const AuthenticationState.idle(user: AuthUser.unauthenticated()));
      },
      error: (error, _) async {
        setState(
          AuthenticationState.idle(
            user: const AuthUser.unauthenticated(),
            // ErrorUtil.formatMessage(error)
            error: kDebugMode ? 'Log Out Error: $error' : 'Log Out Error',
          ),
        );
      },
      name: 'signOut',
    );
  }

  /// Update UserInfo
  // void updateUserInfo(IUserInfo user) => handle(
  //   () async {
  //     final currentUser = state.user;
  //     if (currentUser is! AuthenticatedUser) return;
  //     if (currentUser.userInfo.id != user.id) return;

  //     setState(AuthenticationState.processing(user: state.user, message: 'Updating user information...'));

  //     await _repository.updateUserInfo(user);
  //   },
  //   error: (error, stackTrace) async {
  //     setError('Updating user error', error, stackTrace);
  //     setState(AuthenticationState.idle(user: state.user, error: 'Updating user information error'));
  //   },
  //   done: () async => setState(AuthenticationState.idle(user: _repository.user)),
  // );

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
