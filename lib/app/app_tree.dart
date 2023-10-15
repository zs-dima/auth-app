import 'package:auth_app/app/app_widget.dart';
import 'package:auth_app/app/locale/widget/locale_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppTree extends StatelessWidget {
  const AppTree({super.key});

  // TODO RootRestorationScope( restorationId: 'root', child:

  @override
  Widget build(BuildContext context) => const LocaleScope(
        child: AppWidget(),
      );
}
