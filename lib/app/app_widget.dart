import 'package:auth_app/app/app.dart';
import 'package:auth_app/app/locale/widget/locale_scope.dart';
import 'package:auth_app/app/theme/widget/theme_scope.dart';
import 'package:auth_app/core/widget/window_scope.dart';
import 'package:auth_app/feature/auth/auth_scope.dart';
import 'package:auth_app/feature/auth/widget/sign_in_form.dart';
import 'package:auth_app/feature/users/users_scope.dart';
import 'package:auth_app/feature/users/users_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Auth app',
        debugShowCheckedModeBanner: false,
        supportedLocales: Localization.supportedLocales,
        localizationsDelegates: Localization.localizationDelegates,
        restorationScopeId: 'app_widget',
        locale: LocaleScope.of(context).locale,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.unknown,
          },
        ),
        home: Builder(
          builder: (ctx) => AuthScope.userOf(ctx).isNotAuthenticated
              ? const Scaffold(
                  body: Center(child: SignInForm()),
                )
              : const UsersScope(child: UsersWidget()),
        ),
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(textScaleFactor: 1),
          child: ThemeScope(
            child: WindowScope(
              title: Localization.of(ctx).appTitle,
              height: 24,
              child: AppMessageScope(
                child: AuthScope(child: child ?? const SizedBox.shrink()),
              ),
            ),
          ),
        ),
      );
}
