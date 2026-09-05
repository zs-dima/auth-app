import 'dart:async';

import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:auth_app/_core/message/user_facing_error.dart';
import 'package:auth_app/authentication/controller/authentication_state.dart';
import 'package:auth_app/authentication/data/authentication_repository.dart';
import 'package:auth_model/auth_model.dart' hide AuthenticationState;
import 'package:control/control.dart';
import 'package:flutter/foundation.dart';

final class AuthenticationController extends StateController<AuthenticationState> with SequentialControllerHandler {
  AuthenticationController({
    required IAuthenticationRepository repository,
    required this._messenger,
    super.initialState = const AuthenticationState.idle(user: AuthUser.unauthenticated()),
  }) : _repository = repository {
    _userSubscription = repository.userChanges
        .where((user) => !identical(user, state.user))
        .map<AuthenticationState>((u) => AuthenticationState.idle(user: u))
        .listen(setState, cancelOnError: false);
  }

  final IAuthenticationRepository _repository;
  final UiMessenger _messenger;
  StreamSubscription<AuthenticationState>? _userSubscription;

  /// Restore the session from the cache.
  void restore() => handle(
    () async {
      setState(AuthenticationState.processing(user: state.user, message: 'Restoring session...'));
      final user = await _repository.restore();
      setState(AuthenticationState.idle(user: user));
    },
    error: (error, _) async {
      // No toast: a failed restore lands the user on the sign-in screen, which is its own message.
      _reportSilently('Auth | restore | failed', error, 'Restore Error');
      setState(
        AuthenticationState.idle(
          user: state.user,
          error: kDebugMode ? 'Restore Error: $error' : 'Restore Error',
        ),
      );
    },
    name: 'restore',
  );

  /// Sign in with the given [data].
  /// On MFA required, throws [AuthenticationException] with [AuthResultMfaRequired].
  void signIn(SignInData data, {void Function(MfaChallenge challenge)? onMfaRequired}) => handle(
    () => _messenger.track(() async {
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
    }),
    error: (error, _) async {
      // Handle MFA required - not an error, but a flow continuation
      if (error case AuthenticationException(result: AuthResultMfaRequired(:final mfaChallenge))) {
        if (onMfaRequired == null) {
          // No MFA UI wired for THIS entry point: surface a truthful error instead of silently
          // ending the spinner (a dead-end that looks like nothing happened). The challenge UI
          // exists (mfa_challenge_dialog.dart) — wire onMfaRequired to use it (§16.7).
          const message = 'Multi-factor authentication is required for this account.';
          log('Auth | signIn | mfa not wired').description(message)
            ..warn()
            ..toast(tone: .alert);
          setState(AuthenticationState.idle(user: state.user, error: message));
          return;
        }
        // Leave `processing` before the hand-off, or the form and the MFA dialog stay disabled.
        setState(AuthenticationState.idle(user: state.user));
        onMfaRequired(mfaChallenge);
        return;
      }

      final message = _report('signIn', error, 'Sign In Error');
      setState(AuthenticationState.idle(user: state.user, error: message));
    },
    name: 'signIn',
  );

  /// Complete MFA verification.
  void verifyMfa({
    required String challengeToken,
    required MfaMethod method,
    required String code,
  }) => handle(
    () => _messenger.track(() async {
      setState(AuthenticationState.processing(user: state.user, message: 'Verifying...'));

      final user = await _repository.verifyMfa(
        challengeToken: challengeToken,
        method: method,
        code: code,
      );
      setState(AuthenticationState.idle(user: user, message: 'Successfully logged in.'));
    }),
    error: (error, _) async {
      final message = _report('verifyMfa', error, 'Verification failed');
      setState(AuthenticationState.idle(user: state.user, error: message));
    },
    name: 'verifyMfa',
  );

  /// Register a new account.
  /// On success, user is automatically logged in.
  /// On pending verification, throws [AuthenticationException] with [AuthResultPending].
  void signUp(SignUpData data, {VoidCallback? onSuccess, VoidCallback? onPendingVerification}) => handle(
    () => _messenger.track(() async {
      setState(AuthenticationState.processing(user: state.user, message: 'Creating account...'));

      final user = await _repository.signUp(data);
      onSuccess?.call();
      setState(AuthenticationState.idle(user: user, message: 'Account created successfully.'));
    }),
    error: (error, _) async {
      // Handle pending verification - account created but needs email/phone confirmation
      if (error case AuthenticationException(result: AuthResultPending(:final message))) {
        onPendingVerification?.call();
        setState(
          AuthenticationState.idle(
            user: state.user,
            message: message ?? 'Account created. Please check your email to verify.',
          ),
        );
        return;
      }

      final message = _report('signUp', error, 'Failed to create account');
      setState(AuthenticationState.idle(user: state.user, error: message));
    },
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
      // The user is signed out locally either way, so there is nothing for them to do about it.
      _reportSilently('Auth | signOut | failed', error, 'Sign Out Error');
      setState(
        AuthenticationState.idle(
          user: const AuthUser.unauthenticated(),
          error: kDebugMode ? 'Log Out Error: $error' : 'Log Out Error',
        ),
      );
    },
    // Safety net: drain any progress overlay left behind by a scoped controller whose `done` never
    // balanced a prior `progressStarted` (e.g. its scope was unmounted mid-flight), so the
    // sign-in screen doesn't show a stuck spinner with no event left to clear it.
    done: () async => _messenger.resetProgress(),
    name: 'signOut',
  );

  /// Confirm email/phone verification with token.
  /// On success, user is automatically logged in.
  void confirmVerification({
    required String token,
    required VerificationType type,
    VoidCallback? onSuccess,
  }) => handle(
    () => _messenger.track(() async {
      setState(AuthenticationState.processing(user: state.user, message: 'Verifying...'));

      final user = await _repository.confirmVerification(token: token, type: type);
      onSuccess?.call();
      setState(AuthenticationState.idle(user: user, message: 'Email verified successfully.'));
    }),
    error: (error, _) async {
      final message = _report('confirmVerification', error, 'Verification failed');
      setState(AuthenticationState.idle(user: state.user, error: message));
    },
    name: 'confirmVerification',
  );

  /// Request verification email/SMS resend.
  void requestVerification(VerificationType type, {VoidCallback? onSuccess}) => handle(
    () => _messenger.track(() async {
      setState(AuthenticationState.processing(user: state.user, message: 'Sending verification...'));

      // The API throws a domain error on failure (A4); success always reaches here. Failures are
      // surfaced by the `error:` handler below.
      await _repository.requestVerification(type);
      onSuccess?.call();
      setState(AuthenticationState.idle(user: state.user, message: 'Verification email sent.'));
    }),
    error: (error, _) async {
      // The screen renders `state.error`; no toast on top of it.
      _reportSilently('Auth | requestVerification | failed', error, 'Verification Error');
      setState(
        AuthenticationState.idle(
          user: state.user,
          error: kDebugMode ? 'Verification Error: $error' : 'Failed to send verification email.',
        ),
      );
    },
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
      _reportSilently('Auth | recoveryStart | failed', error, 'Recovery Error');
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
      // The API throws a domain error on failure (A4); success always reaches here.
      await _repository.recoveryConfirm(token: token, newPassword: newPassword);
      onSuccess?.call();
      setState(AuthenticationState.idle(user: state.user, message: 'Password reset email sent.'));
    },
    error: (error, _) async {
      _reportSilently('Auth | recoveryConfirm | failed', error, 'Recovery Error');
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

  /// Records [error], tells the user, and returns the sentence shown.
  ///
  /// [AuthenticationException] is classified here rather than by `describeError`:
  /// it is this feature's type, and every one of its results is something the
  /// user can act on — a wrong password, a locked account, an unverified
  /// address. None is a defect, so none may become a crash-report issue.
  /// Reports a failure that the SCREEN already shows.
  ///
  /// These five paths render the sentence into `state.error` themselves, so the
  /// toast is suppressed ~ but the classification is not. They used to be plain
  /// `log.w`, which meant that after the transport middlewares stopped capturing
  /// (one reporter, one decision) a backend that broke during a password reset
  /// filed nothing at all: `internal` and `unknown` are defects, and only
  /// `describeError` knows that.
  static void _reportSilently(String body, Object error, String caption) =>
      reportFailure(body, error, caption: caption, toast: false);

  static String? _report(String operation, Object error, String caption) => reportFailure(
    'Auth | $operation | failed',
    error,
    caption: kDebugMode ? '$caption: $error' : caption,
    failure: switch (error) {
      AuthenticationException(:final message) => UserFacingError(message, level: .warn),
      _ => null,
    },
  );
}
