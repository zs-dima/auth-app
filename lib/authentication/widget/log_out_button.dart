import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_app/authentication/authentication_scope.dart';
import 'package:flutter/services.dart';
import 'package:ui/ui.dart';

/// {@template log_out_button}
/// LogOutButton widget
/// {@endtemplate}
class LogOutButton extends StatelessWidget {
  /// {@macro log_out_button}
  const LogOutButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.logout),
    tooltip: Localization.of(context).logOutButton,
    onPressed: () => showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Row(
            mainAxisSize: .min,
            mainAxisAlignment: .center,
            crossAxisAlignment: .center,
            children: <Widget>[
              const Icon(Icons.logout, size: 24.0),
              const SizedBox(width: 16.0),
              AppText.headlineSmall(
                Localization.of(context).logOutButton,
                height: 1.0,
                maxLines: 1,
                overflow: .ellipsis,
              ),
              const SizedBox(width: 24.0),
            ],
          ),
        ),
        content: const AppText.bodyMedium(
          'Are you sure you want to log out?',
          textAlign: .center,
        ),
        actionsAlignment: .spaceBetween,
        actions: <Widget>[
          SizedBox(
            height: 48.0,
            width: 128.0,
            child: FilledButton.icon(
              icon: const Icon(Icons.logout),
              label: Text(Localization.of(context).logOutButton),
              onPressed: () {
                AuthenticationScope.signOut(context);
                HapticFeedback.mediumImpact().ignore();
              },
            ),
          ),
          SizedBox(
            height: 48.0,
            width: 128.0,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.cancel),
              label: Text(Localization.of(context).cancelButton),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    ),
  );
}
