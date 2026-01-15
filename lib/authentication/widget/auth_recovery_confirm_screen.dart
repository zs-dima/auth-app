import 'package:auth_app/_core/constant/config.dart';
import 'package:auth_app/_core/message/extension/message_toast.dart';
import 'package:auth_app/_core/router/routes.dart';
import 'package:auth_app/authentication/authentication_scope.dart';
import 'package:auth_app/authentication/controller/authentication_controller.dart';
import 'package:auth_app/authentication/controller/authentication_state.dart';
import 'package:auth_app/authentication/widget/layout/auth_layout.dart';
import 'package:control/control.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

/// {@template auth_recovery_confirm_screen}
/// AuthRecoveryConfirmScreen widget.
/// {@endtemplate}
class AuthRecoveryConfirmScreen extends StatefulWidget {
  /// {@macro auth_recovery_confirm_screen}
  const AuthRecoveryConfirmScreen({
    super.key,
    required this.token,
    required this.lang,
  });

  final String token;
  final String lang;

  @override
  State<AuthRecoveryConfirmScreen> createState() => _AuthRecoveryConfirmScreenState();
}

class _AuthRecoveryConfirmScreenState extends State<AuthRecoveryConfirmScreen> with _PasswordFormStateMixin {
  final _passwordFocusNode = FocusNode();
  late final _formChangedNotifier = Listenable.merge([_passwordController]);

  bool _obscurePassword = true;
  String? _token;

  @override
  void initState() {
    super.initState();

    _token = Uri.decodeFull(widget.token);
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthLayout(
    child: StateConsumer<AuthenticationController, AuthenticationState>(
      controller: _authenticationController,
      buildWhen: (previous, current) => previous != current,
      builder: (context, state, _) => Column(
        children: <Widget>[
          const SizedBox(
            height: 50.0,
            child: Row(
              mainAxisSize: .min,
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: <Widget>[
                SizedBox(width: 50.0),
                AppText.headlineLarge(
                  'Reset Password',
                  height: 1.0,
                  maxLines: 1,
                  overflow: .ellipsis,
                  textAlign: .center,
                ),
                SizedBox(width: 50.0),
              ],
            ),
          ),
          const SizedBox(height: 32.0),
          TextField(
            focusNode: _passwordFocusNode,
            enabled: state.isIdling,
            maxLines: 1,
            minLines: 1,
            controller: _passwordController,
            autocorrect: false,
            obscureText: _obscurePassword,
            maxLength: Config.passwordMaxLength,
            autofillHints: const <String>[AutofillHints.password],
            keyboardType: .visiblePassword,
            onSubmitted: (_) => resetPassword(context),
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              helperText: '',
              helperMaxLines: 1,
              errorText: _passwordError ?? state.error,
              errorMaxLines: 1,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 32.0),
          SizedBox(
            height: 48.0,
            child: AnimatedBuilder(
              animation: _formChangedNotifier,
              builder: (context, _) {
                final formFilled = _passwordController.text.length >= Config.passwordMinLength;
                final resetPasswordCallback = state.isIdling && formFilled ? () => resetPassword(context) : null;
                final key = ValueKey<int>(
                  resetPasswordCallback == null ? 0 : 1 << 1,
                );
                return _AuthRecoveryConfirmScreen$Buttons(
                  key: key,
                  resetPassword: resetPasswordCallback,
                  onCancel: state.isIdling ? () => Navigator.pop(context) : null,
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _AuthRecoveryConfirmScreen$Buttons extends StatelessWidget {
  const _AuthRecoveryConfirmScreen$Buttons({
    super.key,
    required this.resetPassword,
    required this.onCancel,
  });

  final VoidCallback? resetPassword;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: .max,
    crossAxisAlignment: .stretch,
    spacing: 16.0,
    children: <Widget>[
      Expanded(
        flex: 2,
        child: ElevatedButton.icon(
          onPressed: resetPassword,
          icon: const Icon(Icons.lock_reset_outlined),
          label: const Text('Reset password', maxLines: 1, overflow: .ellipsis),
        ),
      ),
      Expanded(
        flex: 1,
        child: FilledButton.tonalIcon(
          onPressed: onCancel,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back', maxLines: 1, overflow: .ellipsis),
        ),
      ),
    ],
  );
}

mixin _PasswordFormStateMixin on State<AuthRecoveryConfirmScreen> {
  late AuthenticationController _authenticationController;
  bool _authControllerInitialized = false;
  final _passwordController = TextEditingController();
  String? _passwordError;

  /// Resets the password using the provided token and new password.
  Future<void> resetPassword(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final password = _passwordController.text;
    _authenticationController.recoveryConfirm(
      token: widget.token,
      newPassword: password,
      onSuccess: () {
        if (context.mounted) {
          context.showInfo(
            'Password has been reset successfully. Please sign in with your new password.',
          );
        }
      },
    );

    await Future<void>.delayed(Durations.long3);
    if (context.mounted) await context.octopus.push(Routes.signin);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_authControllerInitialized) {
      _authenticationController = AuthenticationScope.controllerOf(context);
      _authControllerInitialized = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
  }
}
