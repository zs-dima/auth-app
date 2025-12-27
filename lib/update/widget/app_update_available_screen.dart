import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:auth_app/update/controller/update_check_controller.dart';
import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octopus/octopus.dart';

class AppUpdateAvailableDialog extends StatefulWidget {
  const AppUpdateAvailableDialog({super.key});

  @override
  State<AppUpdateAvailableDialog> createState() => _AppUpdateAvailableDialogState();
}

class _AppUpdateAvailableDialogState extends State<AppUpdateAvailableDialog> {
  late UpdateCheckController _updateCheckController;

  @override
  void initState() {
    super.initState();

    _updateCheckController = context.dependencies.updateCheckController;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      title: Text(
        'New update available',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'New update available',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          StateConsumer<UpdateCheckController, UpdateCheckState>(
            controller: _updateCheckController,
            builder: (_, updateState, __) => Text(
              'A new version (v${updateState.version}) of the app is available.\nPlease update to continue for the best experience.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
            ),
            onPressed: () async {
              HapticFeedback.mediumImpact().ignore();
              // await context.octopus.pop();
              _updateCheckController.update();
              // Future.delayed(
              //   const Duration(milliseconds: 10),
              //   () => _updateCheckController.update(),
              // );
            },
            child: const Text(
              'Update Now',
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact().ignore();
              _updateCheckController.ignoreUpdate();
              context.octopus.pop();
            },
            child: const Text(
              'Maybe Later',
            ),
          ),
        ],
      ),
    );
  }
}
