import 'dart:async';

import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_app/_core/router/routes.dart';
import 'package:auth_app/authentication/controller/authentication_controller.dart';
import 'package:octopus/octopus.dart';

/// Guard that intercepts email-verified route:
/// - RPC flow: extracts token, calls confirmVerification API for auto-login
/// - REST fallback: handles success/status parameter, shows message (manual login required)
class EmailVerifiedGuard extends OctopusGuard {
  EmailVerifiedGuard({required this.authenticationController});

  final AuthenticationController authenticationController;

  @override
  FutureOr<OctopusState> call(
    List<OctopusHistoryEntry> history,
    OctopusState$Mutable state,
    Map<String, Object?> context,
  ) {
    final node = state.findByName(Routes.emailVerified.name);
    if (node == null) return state;

    final token = state.arguments.remove(RouteNode.token) ?? node.arguments[RouteNode.token];
    state.arguments.remove(RouteNode.code);

    if (token != null && token.isNotEmpty) {
      // RPC flow: Call confirmVerification for auto-login
      authenticationController.confirmVerification(
        token: token,
        type: .email,
        onSuccess: () =>
            log('Auth | verification | confirmed').description('Your email has been successfully verified.')
              ..info()
              ..toast(tone: .ok),
      );
    } else {
      // REST fallback: Handle success/status parameter (manual login required)
      final success = state.arguments.remove(RouteNode.success) ?? node.arguments[RouteNode.success];
      final status = state.arguments.remove(RouteNode.status) ?? node.arguments[RouteNode.status];

      if (success == 'true' || status == 'success') {
        log('Auth | verification | confirmed out of band').description('Your email has been verified. Please sign in.')
          ..info()
          ..toast(tone: .ok);
      } else {
        final code = node.arguments[RouteNode.code];
        final msg = switch (code) {
          'invalid_token' ||
          'expired_token' => 'This verification link is no longer valid. Please request a new verification email.',
          'internal_error' => 'An error occurred. Please try again later.',
          _ => 'Email verification failed.',
        };
        log('Auth | verification | link rejected')
            .meta(<String, Object?>{'app.verification.code': code})
            .description(msg)
          ..warn()
          ..toast(tone: .alert);
      }
    }

    // Remove email-verified route. AuthenticationGuard will redirect.
    state.removeWhere((n) => n.name == Routes.emailVerified.name);
    return state;
  }
}
