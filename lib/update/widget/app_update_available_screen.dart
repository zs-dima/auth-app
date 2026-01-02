import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:auth_app/update/controller/update_check_controller.dart';
import 'package:control/control.dart';
import 'package:flutter/services.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

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
  Widget build(BuildContext context) => AlertDialog(
    shape: const RoundedRectangleBorder(
      borderRadius: .all(.circular(16.0)),
    ),
    insetPadding: const .symmetric(horizontal: 40.0, vertical: 24.0),
    contentPadding: const .symmetric(horizontal: 24.0, vertical: 20.0),
    title: const AppText.titleLarge(
      'New update available',
      textAlign: .center,
      fontWeight: .bold,
      // color: colorScheme.onSurface,
    ),
    content: Column(
      mainAxisSize: .min,
      children: [
        const AppText.titleLarge(
          'New update available',
          fontWeight: .bold,
          // color: colorScheme.onSurface,
          textAlign: .center,
        ),
        const SizedBox(height: 28.0),
        StateConsumer<UpdateCheckController, UpdateCheckState>(
          controller: _updateCheckController,
          builder: (_, updateState, __) => AppText.bodyLarge(
            'A new version (v${updateState.version}) of the app is available.\nPlease update to continue for the best experience.',
            textAlign: .center,
          ),
        ),
        const SizedBox(height: 32.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: .all(.circular(12.0)),
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
        const SizedBox(height: 10.0),
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
