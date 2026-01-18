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
  /// On MFA required, throws [AuthenticationException] with [AuthResultMfaRequired].
  void signIn(SignInData data, {void Function(MfaChallenge challenge)? onMfaRequired}) => handle(
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
      // Handle MFA required - not an error, but a flow continuation
      if (error case AuthenticationException(result: AuthResultMfaRequired(:final mfaChallenge))) {
        setProgressDone();
        onMfaRequired?.call(mfaChallenge);
        return;
      }

      // Handle specific auth errors with user-friendly messages
      final errorMessage = switch (error) {
        AuthenticationException(:final message) => message,
        _ => kDebugMode ? 'Sign In Error: $error' : 'Sign In Error',
      };

      setError(errorMessage);
      setState(AuthenticationState.idle(user: state.user, error: errorMessage));
    },
    done: () async => setProgressDone(),
    name: 'signIn',
  );

  /// Complete MFA verification.
  void verifyMfa({
    required String challengeToken,
    required MfaMethod method,
    required String code,
  }) => handle(
    () async {
      setProgressStarted();
      setState(AuthenticationState.processing(user: state.user, message: 'Verifying...'));

      final user = await _repository.verifyMfa(
        challengeToken: challengeToken,
        method: method,
        code: code,
      );
      setState(AuthenticationState.idle(user: user, message: 'Successfully logged in.'));
    },
    error: (error, _) async {
      final errorMessage = switch (error) {
        AuthenticationException(:final message) => message,
        _ => kDebugMode ? 'Verification Error: $error' : 'Verification failed',
      };

      setError(errorMessage);
      setState(AuthenticationState.idle(user: state.user, error: errorMessage));
    },
    done: () async => setProgressDone(),
    name: 'verifyMfa',
  );

  /// Register a new account.
  /// On success, user is automatically logged in.
  /// On pending verification, throws [AuthenticationException] with [AuthResultPending].
  void signUp(SignUpData data, {VoidCallback? onSuccess, VoidCallback? onPendingVerification}) => handle(
    () async {
      setProgressStarted();
      setState(AuthenticationState.processing(user: state.user, message: 'Creating account...'));

      final user = await _repository.signUp(data);
      onSuccess?.call();
      setState(AuthenticationState.idle(user: user, message: 'Account created successfully.'));
    },
    error: (error, _) async {
      // Handle pending verification - account created but needs email/phone confirmation
      if (error case AuthenticationException(result: AuthResultPending(:final message))) {
        setProgressDone();
        onPendingVerification?.call();
        setState(
          AuthenticationState.idle(
            user: state.user,
            message: message ?? 'Account created. Please check your email to verify.',
          ),
        );
        return;
      }

      final errorMessage = switch (error) {
        AuthenticationException(:final message) => message,
        _ => kDebugMode ? 'Sign Up Error: $error' : 'Failed to create account',
      };

      setError(errorMessage);
      setState(AuthenticationState.idle(user: state.user, error: errorMessage));
    },
    done: () async => setProgressDone(),
    name: 'signUp',
  );

  /// Sign out.
  void signOut() => handle(
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

  /// Confirm email/phone verification with token.
  /// On success, user is automatically logged in.
  void confirmVerification({
    required String token,
    required VerificationType type,
    VoidCallback? onSuccess,
  }) => handle(
    () async {
      setProgressStarted();
      setState(AuthenticationState.processing(user: state.user, message: 'Verifying...'));

      final user = await _repository.confirmVerification(token: token, type: type);
      onSuccess?.call();
      setState(AuthenticationState.idle(user: user, message: 'Email verified successfully.'));
    },
    error: (error, _) async {
      final errorMessage = switch (error) {
        AuthenticationException(:final message) => message,
        _ => kDebugMode ? 'Verification Error: $error' : 'Verification failed',
      };

      setError(errorMessage);
      setState(AuthenticationState.idle(user: state.user, error: errorMessage));
    },
    done: () async => setProgressDone(),
    name: 'confirmVerification',
  );

  /// Request verification email/SMS resend.
  void requestVerification(VerificationType type, {VoidCallback? onSuccess}) => handle(
    () async {
      setProgressStarted();
      setState(AuthenticationState.processing(user: state.user, message: 'Sending verification...'));

      final success = await _repository.requestVerification(type);
      if (success) {
        onSuccess?.call();
        setState(AuthenticationState.idle(user: state.user, message: 'Verification email sent.'));
      } else {
        setState(AuthenticationState.idle(user: state.user, error: 'Failed to send verification email.'));
      }
    },
    error: (error, _) async {
      setState(
        AuthenticationState.idle(
          user: state.user,
          error: kDebugMode ? 'Verification Error: $error' : 'Failed to send verification email.',
        ),
      );
    },
    done: () async => setProgressDone(),
    name: 'requestVerification',
  );

  /// Reset password for the given [email].
  void recoveryStart(String email, {VoidCallback? onSuccess}) => handle(
    () async {
      setState(AuthenticationState.processing(user: state.user, message: 'Sending reset email...'));
      final success = await _repository.recoveryStart(email);
      if (success) {
        onSuccess?.call();
        setState(AuthenticationState.idle(user: state.user, message: 'Password reset email sent.'));
      } else {
        setState(AuthenticationState.idle(user: state.user, error: 'Failed to send reset email.'));
      }
    },
    error: (error, _) async {
      setState(
        AuthenticationState.idle(
          user: state.user,
          error: kDebugMode ? 'Reset Password Error: $error' : 'Failed to send reset email.',
        ),
      );
    },
    name: 'resetPassword',
  );

  void recoveryConfirm({required String token, required String newPassword, VoidCallback? onSuccess}) => handle(
    () async {
      setState(AuthenticationState.processing(user: state.user, message: 'Sending reset email...'));
      final success = await _repository.recoveryConfirm(token: token, newPassword: newPassword);
      if (success) {
        onSuccess?.call();
        setState(AuthenticationState.idle(user: state.user, message: 'Password reset email sent.'));
      } else {
        setState(AuthenticationState.idle(user: state.user, error: 'Failed to send reset email.'));
      }
    },
    error: (error, _) async {
      setState(
        AuthenticationState.idle(
          user: state.user,
          error: kDebugMode ? 'Reset Password Error: $error' : 'Failed to send reset email.',
        ),
      );
    },
    name: 'resetPassword',
  );

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
