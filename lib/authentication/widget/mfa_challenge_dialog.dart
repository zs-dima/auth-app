import 'dart:async';

import 'package:auth_app/authentication/authentication_scope.dart';
import 'package:auth_app/authentication/controller/authentication_controller.dart';
import 'package:auth_app/authentication/controller/authentication_state.dart';
import 'package:auth_model/auth_model.dart' hide AuthenticationState;
import 'package:control/control.dart';
import 'package:flutter/material.dart';

/// Shows the second-factor dialog for [challenge] (refresh_token.md §16 — MFA UX).
///
/// Wire to [AuthenticationController.signIn]'s `onMfaRequired`. The dialog submits the code via
/// [AuthenticationController.verifyMfa], surfaces controller errors inline, and dismisses itself
/// once an authenticated user is published (the router guard takes over navigation from there).
Future<void> showMfaChallengeDialog(BuildContext context, MfaChallenge challenge) => showDialog<void>(
  context: context,
  useRootNavigator: false,
  builder: (_) => MfaChallengeDialog(challenge: challenge),
);

/// {@template mfa_challenge_dialog}
/// Second-factor verification dialog: method picker (when several are available), one-time code
/// entry, inline errors from the authentication state.
/// {@endtemplate}
class MfaChallengeDialog extends StatefulWidget {
  /// {@macro mfa_challenge_dialog}
  const MfaChallengeDialog({super.key, required this.challenge});

  final MfaChallenge challenge;

  @override
  State<MfaChallengeDialog> createState() => _MfaChallengeDialogState();
}

class _MfaChallengeDialogState extends State<MfaChallengeDialog> {
  static String _methodLabel(MfaMethod method) => switch (method) {
    .totp => 'Authenticator app',
    .sms => 'SMS code',
    .email => 'Email code',
    .recoveryCode => 'Recovery code',
  };
  final _codeController = TextEditingController();

  final _codeFocusNode = FocusNode();
  late MfaMethodInfo _method;
  AuthenticationController? _controller;
  StreamSubscription<AuthenticationState>? _subscription;

  String? _localError;

  @override
  void initState() {
    super.initState();
    final methods = widget.challenge.availableMethods;
    // Defensive: a challenge should always carry methods; degrade to TOTP entry if not.
    _method = methods.isEmpty
        ? const MfaMethodInfo(method: .totp, hint: '')
        : methods.firstWhere((m) => m.isDefault, orElse: () => methods.first);
  }

  void _verify() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _localError = 'Enter the verification code');
      return;
    }
    if (widget.challenge.isExpired) {
      setState(() => _localError = 'The challenge has expired — close this dialog and sign in again');
      return;
    }
    setState(() => _localError = null);
    _controller?.verifyMfa(
      challengeToken: widget.challenge.challengeToken,
      method: _method.method,
      code: code,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      final controller = AuthenticationScope.controllerOf(context);
      _controller = controller;
      // On success the dialog only has to leave — the guard handles navigation.
      _subscription = controller.toStream().listen(
        (state) {
          if (state.user.isAuthenticated && mounted) Navigator.of(context).pop();
        },
        cancelOnError: false,
      );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();
    final methods = widget.challenge.availableMethods;

    return StateConsumer<AuthenticationController, AuthenticationState>(
      controller: controller,
      builder: (context, state, _) {
        final busy = !state.isIdling;
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: .all(.circular(7.0))),
          title: const Text('Two-factor verification', maxLines: 1, overflow: .ellipsis),
          content: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: <Widget>[
              if (methods.length > 1) ...[
                DropdownButtonFormField<MfaMethodInfo>(
                  initialValue: _method,
                  decoration: const InputDecoration(labelText: 'Method'),
                  items: methods
                      .map(
                        (m) => DropdownMenuItem<MfaMethodInfo>(
                          value: m,
                          child: Text(
                            m.hint.isEmpty ? _methodLabel(m.method) : '${_methodLabel(m.method)} (${m.hint})',
                            maxLines: 1,
                            overflow: .ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: busy ? null : (m) => setState(() => _method = m ?? _method),
                ),
                const SizedBox(height: 16.0),
              ] else if (_method.hint.isNotEmpty) ...[
                Text('${_methodLabel(_method.method)}: ${_method.hint}', maxLines: 1, overflow: .ellipsis),
                const SizedBox(height: 16.0),
              ],
              TextField(
                controller: _codeController,
                focusNode: _codeFocusNode,
                enabled: !busy,
                autofocus: true,
                autocorrect: false,
                maxLines: 1,
                // Recovery codes may be alphanumeric — do not restrict to digits.
                keyboardType: _method.method == .recoveryCode ? .text : .number,
                onSubmitted: (_) => _verify(),
                decoration: InputDecoration(
                  labelText: 'Verification code',
                  hintText: 'Enter the one-time code',
                  errorText: _localError ?? state.error,
                  errorMaxLines: 2,
                  prefixIcon: const Icon(Icons.pin_outlined),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: busy ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: busy ? null : _verify,
              child: busy
                  ? const SizedBox.square(
                      dimension: 16.0,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    )
                  : const Text('Verify'),
            ),
          ],
        );
      },
    );
  }
}
