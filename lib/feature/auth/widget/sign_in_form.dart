import 'dart:math' as math;

import 'package:auth_app/app/environment/model/app_environment.dart';
import 'package:auth_app/app/initialization/model/dependencies.dart';
import 'package:auth_app/app/theme/extension/theme_sizes.dart';
import 'package:auth_app/core/localization/localization.dart';
import 'package:auth_app/feature/auth/auth_scope.dart';
import 'package:auth_app/feature/auth/bloc/auth_bloc.dart';
import 'package:auth_app/feature/auth/data/model/sign_in_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template sign_in_form}
/// SignInScreen widget.
/// {@endtemplate}
class SignInForm extends StatelessWidget implements PreferredSizeWidget {
  /// {@macro sign_in_form}
  const SignInForm({super.key});

  /// Width of the sign in form.
  static const double width = 480;

  /// Height of the sign in form.
  static const double height = 720;

  @override
  Size get preferredSize => const Size(width, height);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final space = math.min(
            constraints.maxHeight - preferredSize.height,
            constraints.maxWidth - preferredSize.width,
          );
          final padding = switch (space) {
            > 32 => ThemePaddings.defaultLarge.medium,
            > 24 => ThemePaddings.defaultMedium.medium,
            > 16 => ThemePaddings.defaultSmall.medium,
            _ => EdgeInsets.zero,
          };
          Widget wrap({required Widget child}) => padding.top > 0
              ? SizedBox(
                  width: width,
                  height: height,
                  child: child,
                )
              : SizedBox.expand(
                  child: child,
                );
          return wrap(
            child: Card(
              elevation: padding.top > 0 ? 8 : 0,
              margin: padding,
              shape: padding.top > 0
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(padding.top),
                    )
                  : const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              child: const _SignInForm(),
            ),
          );
        },
      );
}

class _SignInForm extends StatefulWidget {
  const _SignInForm();

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

/// State for widget _SignInForm.
class _SignInFormState extends State<_SignInForm> {
  // Make it static so that it doesn't get disposed when the widget is rebuilt.
  static final TextEditingController _loginController = TextEditingController();
  static final TextEditingController _passwordController = TextEditingController();

  final FocusNode _loginFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final ValueNotifier<String?> _loginError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _passwordError = ValueNotifier<String?>(null);

  final ValueNotifier<bool> _validNotifier = ValueNotifier<bool>(false);

  late final AuthController authenticationController;
  late final Listenable _observer;

  IAppEnvironment? _environment;

  @override
  void initState() {
    super.initState();

    authenticationController = context.auth();

    if (kDebugMode) {
      _loginController.text = 'admin@mail.com';
      _passwordController.text = 'admin';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final environment = context.dependencies.environment;
    if (_environment != environment) {
      _environment = environment;

      _observer = Listenable.merge(<TextEditingController>[
        _loginController,
        _passwordController,
      ])
        ..addListener(_onChanged);
      _onChanged();
    }
  }

  @override
  void dispose() {
    _observer.removeListener(_onChanged);
    _validNotifier.dispose();
    super.dispose();
  }

  late SignInData _data;

  void _onChanged() {
    if (!mounted) return;

    _data = SignInData(
      login: _loginController.text,
      password: _passwordController.text,
      installationId: context.dependencies.settings.installationId,
    );

    _validNotifier.value = _validate(_data);
  }

  late final List<String? Function(SignInData data)> _validators = <String? Function(SignInData data)>[
    (data) => _loginError.value = data.isValidLogin(),
    (data) => _passwordError.value = data.isValidPassword(),
  ];
  bool _validate(SignInData data) {
    for (final validator in _validators) {
      if (validator(data) != null) return false;
    }
    return true;
  }

  void _submit() {
    final data = _data;
    if (!_validate(data)) return;
    authenticationController.signIn(data);
  }

  @override
  Widget build(BuildContext context) => FocusScope(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Text(
                      context.l10n.signInButton,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SignInTextField(
                    focusNode: _loginFocusNode,
                    controller: _loginController,
                    error: _loginError,
                    maxLength: 64,
                    labelText: 'Email',
                    hintText: 'Select your username',
                    autofillHints: const <String>[
                      AutofillHints.email,
                    ],
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        /// Allow only letters, numbers, and the following characters: @.-_+
                        RegExp(r'\@|[A-Z]|[a-z]|[0-9]|\.|\-|\_|\+'),
                      ),
                    ],
                    onSubmitted: (_) => _submit(),
                  ),
                  SignInTextField(
                    focusNode: _passwordFocusNode,
                    controller: _passwordController,
                    error: _passwordError,
                    maxLength: 64,
                    autofillHints: const <String>[
                      AutofillHints.password,
                    ],
                    keyboardType: TextInputType.visiblePassword,
                    labelText: 'Password',
                    hintText: 'Enter password',
                    obscureText: true,
                    onSubmitted: (_) => _submit(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 320,
                  height: 64,
                  child: ValueListenableBuilder(
                    valueListenable: _validNotifier,
                    builder: (context, valid, _) => AnimatedOpacity(
                      opacity: valid ? 1 : .5,
                      duration: const Duration(milliseconds: 350),
                      child: ElevatedButton(
                        onPressed: valid ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(24),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Connect'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class SignInTextField extends StatefulWidget {
  const SignInTextField({
    super.key,
    required this.controller,
    this.inputFormatters,
    this.focusNode,
    this.error,
    this.autofillHints,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.maxLength,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final ValueListenable<String?>? error;
  final List<String>? autofillHints;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final ValueChanged<String>? onSubmitted;

  @override
  State<SignInTextField> createState() => _SignInTextFieldState();
}

class _SignInTextFieldState extends State<SignInTextField> {
  bool _obscurePassword = false;
  FocusNode? focusNode;

  @override
  void initState() {
    super.initState();
    _obscurePassword = widget.obscureText;
    focusNode = widget.focusNode?..addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    focusNode?.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    if (focusNode?.hasFocus == false && mounted && widget.obscureText && !_obscurePassword) {
      setState(() => _obscurePassword = true);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: BlocBuilder<AuthBloc, AuthState>(
          bloc: context.auth().bloc,
          builder: (context, state) {
            final idle = state.whenOrNull(idle: (_, __, ___) => true) ?? false;
            return AnimatedOpacity(
              opacity: idle ? 1 : .5,
              duration: const Duration(milliseconds: 250),
              child: ValueListenableBuilder<String?>(
                valueListenable: widget.error ?? ValueNotifier<String?>(null),
                builder: (context, error, child) => StatefulBuilder(
                  builder: (context, setState) => TextField(
                    focusNode: widget.focusNode,
                    enabled: idle,
                    maxLines: 1,
                    minLines: 1,
                    maxLength: widget.maxLength,
                    controller: widget.controller,
                    autocorrect: false,
                    autofillHints: widget.autofillHints,
                    keyboardType: widget.keyboardType,
                    inputFormatters: widget.inputFormatters,
                    obscureText: _obscurePassword,
                    onSubmitted: widget.onSubmitted,
                    decoration: InputDecoration(
                      constraints: const BoxConstraints(maxHeight: 84),
                      labelText: widget.labelText,
                      hintText: widget.hintText,
                      helperText: '',
                      helperMaxLines: 1,
                      errorText: error ?? state.whenOrNull(idle: (_, __, error) => error),
                      errorMaxLines: 1,
                      suffixIcon: widget.obscureText
                          ? IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                HapticFeedback.mediumImpact().ignore();
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
}
