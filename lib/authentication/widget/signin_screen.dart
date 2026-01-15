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

/// {@template signin_screen}
/// SignInScreen widget.
/// {@endtemplate}
class SignInScreen extends StatefulWidget {
  /// {@macro signin_screen}
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with _UsernamePasswordFormStateMixin {
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  late final _formChangedNotifier = Listenable.merge([_emailController, _passwordController]);
  final _emailFormatters = <TextInputFormatter>[
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
    _emailFocusNode.dispose();
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
                  'Sign-In',
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
            focusNode: _emailFocusNode,
            enabled: state.isIdling,
            maxLines: 1,
            minLines: 1,
            controller: _emailController,
            autocorrect: false,
            autofillHints: const <String>[AutofillHints.username, AutofillHints.email],
            keyboardType: .emailAddress,
            inputFormatters: _emailFormatters,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              helperText: '',
              helperMaxLines: 1,
              errorText: _emailError ?? state.error,
              errorMaxLines: 1,
              prefixIcon: const Icon(Icons.person),
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
            onSubmitted: (_) => signIn(context),
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
                final formFilled =
                    _emailController.text.length > 3 && _passwordController.text.length >= Config.passwordMinLength;
                final signInCallback = state.isIdling && formFilled ? () => signIn(context) : null;
                final signUpCallback = state.isIdling ? () => signUp(context) : null;
                final key = ValueKey<int>(
                  (signInCallback == null ? 0 : 1 << 1) | (signUpCallback == null ? 0 : 1),
                );
                return _SignInScreen$Buttons(signIn: signInCallback, signUp: signUpCallback, key: key);
              },
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              if (!state.isIdling) return;
              FocusScope.of(context).unfocus();
              context.octopus.push(Routes.authRecoveryStart);
            },
            child: Text(
              'Forgot password?',
              maxLines: 1,
              overflow: .ellipsis,
              style: TextStyle(
                color: context.theme.colorScheme.primary,
                decoration: .underline,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SignInScreen$Buttons extends StatelessWidget {
  const _SignInScreen$Buttons({required this.signIn, required this.signUp, super.key});

  final VoidCallback? signIn;
  final VoidCallback? signUp;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: .max,
    crossAxisAlignment: .stretch,
    spacing: 16.0,
    children: <Widget>[
      Expanded(
        flex: 2,
        child: ElevatedButton.icon(
          onPressed: signIn,
          icon: const Icon(Icons.login),
          label: const Text('Sign-In', maxLines: 1, overflow: .ellipsis),
        ),
      ),
      Expanded(
        flex: 1,
        child: FilledButton.tonalIcon(
          onPressed: signUp,
          icon: const Icon(Icons.person_add),
          label: const Text('Sign-Up', maxLines: 1, overflow: .ellipsis),
        ),
      ),
    ],
  );
}

class _UsernameTextFormatter extends TextInputFormatter {
  const _UsernameTextFormatter();
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      .new(text: newValue.text.toLowerCase(), selection: newValue.selection);
}

mixin _UsernamePasswordFormStateMixin on State<SignInScreen> {
  late AuthenticationController _authenticationController;
  bool _authControllerInitialized = false;
  final _emailController = TextEditingController(text: 'test@gmail.com');
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  /// Signs in the user with the given email and password
  void signIn(BuildContext context) {
    final email = _emailController.text;
    final password = _passwordController.text;
    _authenticationController.signIn(
      SignInData(
        identifierType: .email,
        identifier: email,
        password: password,
      ),
    );
    // Unfocus after initiating sign-in to avoid interrupting the tap gesture
    FocusScope.of(context).unfocus();
  }

  /// Opens the sign up page in the browser
  void signUp(BuildContext context) {
    FocusScope.of(context).unfocus();
    // url_launcher.launchUrlString('...').ignore();
    // context.octopus.setState((state) => state..add(Routes.signup.node()));
    context.octopus.push(Routes.signup);
  }

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      _emailController.text = 'admin@mail.com';
      _passwordController.text = 'admin';
    }
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
    _emailController.dispose();
    _passwordController.dispose();
  }
}
