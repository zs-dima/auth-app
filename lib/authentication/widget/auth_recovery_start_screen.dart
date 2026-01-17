import 'package:auth_app/_core/message/app_message_scope.dart';
import 'package:auth_app/authentication/authentication_scope.dart';
import 'package:auth_app/authentication/controller/authentication_controller.dart';
import 'package:auth_app/authentication/controller/authentication_state.dart';
import 'package:auth_app/authentication/widget/layout/auth_layout.dart';
import 'package:control/control.dart';
import 'package:flutter/services.dart';
import 'package:ui/ui.dart';

/// {@template auth_recovery_start_screen}
/// AuthRecoveryStartScreen widget.
/// {@endtemplate}
class AuthRecoveryStartScreen extends StatefulWidget {
  /// {@macro auth_recovery_start_screen}
  const AuthRecoveryStartScreen({super.key});

  @override
  State<AuthRecoveryStartScreen> createState() => _AuthRecoveryStartScreenState();
}

class _AuthRecoveryStartScreenState extends State<AuthRecoveryStartScreen> {
  AuthenticationController? _authenticationController;
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  String? _emailError;

  static final _emailFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'\@|[A-Z]|[a-z]|[0-9]|\.|\-|\_|\+')),
    const _LowercaseTextFormatter(),
  ];

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required.';
    if (email.length < 5) return 'Please enter a valid email.';
    final parts = email.split('@').where((e) => e.isNotEmpty);
    if (parts.length != 2) return 'Please enter a valid email.';
    if (!email.contains('.')) return 'Please enter a valid email.';
    return null;
  }

  void _submit() {
    final email = _emailController.text.trim();
    final error = _validateEmail(email);
    if (error != null) {
      setState(() => _emailError = error);
      return;
    }
    setState(() => _emailError = null);
    FocusScope.of(context).unfocus();
    _authenticationController?.recoveryStart(email, onSuccess: () => Navigator.pop(context));
    context.message.showAppMessage('If an account with that email exists, a reset link has been sent.');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authenticationController = AuthenticationScope.controllerOf(context);
    if (_authenticationController != authenticationController) {
      _authenticationController = authenticationController;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthLayout(
    child: StateConsumer<AuthenticationController, AuthenticationState>(
      controller: _authenticationController,
      buildWhen: (previous, current) => previous != current,
      builder: (context, state, _) => Column(
        mainAxisAlignment: .center,
        children: <Widget>[
          const SizedBox(
            height: 50.0,
            child: AppText.headlineLarge(
              'Reset Password',
              height: 1.0,
              maxLines: 1,
              overflow: .ellipsis,
              textAlign: .center,
            ),
          ),
          const SizedBox(height: 32.0),
          TextField(
            focusNode: _emailFocusNode,
            enabled: state.isIdling,
            maxLines: 1,
            minLines: 1,
            controller: _emailController,
            autocorrect: false,
            autofillHints: const <String>[AutofillHints.email],
            keyboardType: .emailAddress,
            inputFormatters: _emailFormatters,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              helperText: '',
              helperMaxLines: 1,
              errorText: _emailError ?? state.error,
              errorMaxLines: 1,
              prefixIcon: const Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 32.0),
          SizedBox(
            height: 48.0,
            child: AnimatedBuilder(
              animation: _emailController,
              builder: (context, _) {
                final canSubmit = state.isIdling && _emailController.text.length > 4;
                return _AuthRecoveryStartScreen$Buttons(
                  onSubmit: canSubmit ? _submit : null,
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

class _LowercaseTextFormatter extends TextInputFormatter {
  const _LowercaseTextFormatter();
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      .new(text: newValue.text.toLowerCase(), selection: newValue.selection);
}

class _AuthRecoveryStartScreen$Buttons extends StatelessWidget {
  const _AuthRecoveryStartScreen$Buttons({
    required this.onSubmit,
    required this.onCancel,
  });

  final VoidCallback? onSubmit;
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
          onPressed: onSubmit,
          icon: const Icon(Icons.send),
          label: const Text('Send Reset Link', maxLines: 1, overflow: .ellipsis),
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
