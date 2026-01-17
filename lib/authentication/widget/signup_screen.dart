import 'dart:math' as math;

import 'package:auth_app/_core/constant/config.dart';
import 'package:auth_app/_core/router/routes.dart';
import 'package:auth_app/authentication/authentication_scope.dart';
import 'package:auth_app/authentication/controller/authentication_controller.dart';
import 'package:auth_app/authentication/controller/authentication_state.dart';
import 'package:auth_app/authentication/widget/layout/auth_layout.dart';
import 'package:auth_model/auth_model.dart' hide AuthenticationState;
import 'package:control/control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

/// {@template signup_screen}
/// SignUpScreen widget.
/// {@endtemplate}
class SignUpScreen extends StatefulWidget {
  /// {@macro signup_screen}
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with _UsernamePasswordFormStateMixin {
  final _displayNameFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _usernameFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(
      /// Allow only letters, numbers,
      /// and the following characters: @.-_+
      RegExp(r'\@|[A-Z]|[a-z]|[0-9]|\.|\-|\_|\+'),
    ),
    const _UsernameTextFormatter(),
  ];
  bool _obscurePassword = true;

  @override
  void dispose() {
    _displayNameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
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
              'Sign-Up',
              height: 1.0,
              maxLines: 1,
              overflow: .ellipsis,
              textAlign: .center,
            ),
          ),
          const SizedBox(height: 32.0),
          TextField(
            focusNode: _displayNameFocusNode,
            enabled: state.isIdling,
            maxLines: 1,
            minLines: 1,
            controller: _displayNameController,
            autocorrect: false,
            autofillHints: const <String>[AutofillHints.name],
            keyboardType: .name,
            textCapitalization: .words,
            onSubmitted: (_) => _usernameFocusNode.requestFocus(),
            decoration: InputDecoration(
              labelText: 'Display Name',
              hintText: 'Enter your name',
              helperText: '',
              helperMaxLines: 1,
              errorText: _displayNameError,
              errorMaxLines: 1,
              prefixIcon: const Icon(Icons.badge),
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            focusNode: _usernameFocusNode,
            enabled: state.isIdling,
            maxLines: 1,
            minLines: 1,
            controller: _usernameController,
            autocorrect: false,
            autofillHints: const <String>[AutofillHints.username, AutofillHints.email],
            keyboardType: .emailAddress,
            inputFormatters: _usernameFormatters,
            onSubmitted: (_) => _passwordFocusNode.requestFocus(),
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              helperText: '',
              helperMaxLines: 1,
              errorText: _usernameError ?? state.error,
              errorMaxLines: 1,
              prefixIcon: const Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 8.0),
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
            onSubmitted: (_) => _signUp(context),
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              helperText: '',
              helperMaxLines: 1,
              errorText: _passwordError ?? state.error,
              errorMaxLines: 1,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: Row(
                mainAxisSize: .min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.casino),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 48.0,
                      height: 48.0,
                    ),
                    tooltip: 'Generate password',
                    onPressed: state.isIdling
                        ? () {
                            if (_obscurePassword) {
                              setState(() => _obscurePassword = false);
                            }
                            generatePassword();
                          }
                        : null,
                  ),
                  IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32.0),
          SizedBox(
            height: 48.0,
            child: _SignUpScreen$Buttons(
              cancel: () => Navigator.pop(context),
              signUp: state.isIdling ? () => _signUp(context) : null,
            ),
          ),
        ],
      ),
    ),
  );
}

class _SignUpScreen$Buttons extends StatelessWidget {
  const _SignUpScreen$Buttons({
    required this.signUp,
    required this.cancel,
  });

  final VoidCallback? signUp;
  final VoidCallback? cancel;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: .max,
    crossAxisAlignment: .stretch,
    spacing: 16.0,
    children: <Widget>[
      Expanded(
        flex: 2,
        child: ElevatedButton.icon(
          onPressed: signUp,
          icon: const Icon(Icons.person_add),
          label: const Text(
            'Sign-Up',
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: FilledButton.tonalIcon(
          onPressed: cancel,
          icon: const Icon(Icons.cancel),
          label: const Text(
            'Cancel',
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
      ),
    ],
  );
}

class _UsernameTextFormatter extends TextInputFormatter {
  const _UsernameTextFormatter();
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) => .new(
    text: newValue.text.toLowerCase(),
    selection: newValue.selection,
  );
}

mixin _UsernamePasswordFormStateMixin on State<SignUpScreen> {
  static String? _displayNameValidator(String name) {
    if (name.isEmpty) return 'Name is required.';
    if (name.length < 2) return 'Name must be at least 2 characters.';
    if (name.length > 100) return 'Name must be 100 characters or less.';
    return null;
  }

  static String? _usernameValidator(String username) {
    if (username.isEmpty) return 'Email is required.';
    if (username.length < 3) return 'Must be a valid email.';
    // Simple email validation
    return username.split('@').where((e) => e.isNotEmpty).length == 2 ? null : 'Must be a valid email.';
  }

  static String? _passwordValidator(String password) {
    const passwordMinLength = Config.passwordMinLength;
    const passwordMaxLength = Config.passwordMaxLength;
    return switch (password.length) {
      0 => 'Password is required.',
      < passwordMinLength => 'Password must be $passwordMinLength characters or more.',
      > passwordMaxLength => 'Password must be $passwordMaxLength characters or less.',
      _ => null,
    };
  }

  late final AuthenticationController _authenticationController;
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _displayNameError;
  String? _usernameError;
  String? _passwordError;

  bool _validate() {
    final displayNameError = _displayNameValidator(_displayNameController.text);
    final usernameError = _usernameValidator(_usernameController.text);
    final passwordError = _passwordValidator(_passwordController.text);
    if (mounted) {
      setState(() {
        _displayNameError = displayNameError;
        _usernameError = usernameError;
        _passwordError = passwordError;
      });
    }
    return displayNameError == null && usernameError == null && passwordError == null;
  }

  /// Generates a random password
  void generatePassword() {
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const chars = lower + upper + numbers;
    final rnd = math.Random();
    final length = rnd.nextInt(Config.passwordMaxLength - Config.passwordMinLength) + Config.passwordMinLength;
    final password = <int>[
      lower.codeUnitAt(rnd.nextInt(lower.length)),
      upper.codeUnitAt(rnd.nextInt(upper.length)),
      numbers.codeUnitAt(rnd.nextInt(numbers.length)),
      for (var i = 0; i < length - 3; i++) chars.codeUnitAt(rnd.nextInt(chars.length)),
    ];
    _passwordController.text = String.fromCharCodes(password..shuffle());
  }

  /// Sign up with the provided credentials
  void _signUp(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    final data = SignUpData.email(
      email: _usernameController.text,
      password: _passwordController.text,
      displayName: _displayNameController.text,
    );

    _authenticationController.signUp(
      data,
      onSuccess: () => context.octopus.setState(
        (s) => s
          ..clear()
          ..add(Routes.signin.node()),
      ),
      onPendingVerification: () => context.octopus.setState(
        (s) => s
          ..clear()
          ..add(Routes.signin.node()),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    generatePassword();

    if (kDebugMode) {
      _displayNameController.text = 'Test User';
      _usernameController.text = 'test@example.com';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authenticationController = AuthenticationScope.controllerOf(context);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
