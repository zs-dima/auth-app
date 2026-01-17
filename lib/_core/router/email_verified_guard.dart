import 'dart:async';

import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_app/_core/router/routes.dart';
import 'package:octopus/octopus.dart';

/// Guard that intercepts email-verified route:
/// extracts status/code, queues message, removes route.
class EmailVerifiedGuard extends OctopusGuard {
  EmailVerifiedGuard({required this.messageController});

  final AppMessageController messageController;

  @override
  FutureOr<OctopusState> call(
    List<OctopusHistoryEntry> history,
    OctopusState$Mutable state,
    Map<String, Object?> context,
  ) {
    final node = state.findByName(Routes.emailVerified.name);
    if (node == null) return state;

    final status = state.arguments.remove(RouteNode.status) ?? node.arguments[RouteNode.status];
    state.arguments.remove(RouteNode.code);

    if (status == 'success') {
      messageController.showAppMessage('Your email has been successfully verified.');
    } else {
      final code = node.arguments[RouteNode.code];
      final msg = switch (code) {
        'invalid_token' ||
        'expired_token' => 'This verification link is no longer valid. Please request a new verification email.',
        'internal_error' => 'An error occurred. Please try again later.',
        _ => 'Email verification failed.',
      };
      messageController.showAppError(msg);
    }

    // Remove email-verified route. AuthenticationGuard will redirect.
    state.removeWhere((n) => n.name == Routes.emailVerified.name);
    return state;
  }
}
