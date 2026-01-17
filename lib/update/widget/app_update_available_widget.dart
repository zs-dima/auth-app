import 'package:auth_app/update/controller/update_check_controller.dart';
import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppUpdateAvailableWidget extends MaterialBanner {
  AppUpdateAvailableWidget(
    BuildContext context, {
    super.key,
    required UpdateCheckController updateCheckController,
  }) : super(
         // backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
         leading: Icon(Icons.cloud_download_outlined, color: Theme.of(context).colorScheme.onSecondaryContainer),
         content: StateConsumer<UpdateCheckController, UpdateCheckState>(
           controller: updateCheckController,
           builder: (_, updateState, __) => Text.rich(
             TextSpan(
               text: 'A new version (v${updateState.version}) of the app is available.\n',
               style: Theme.of(context).textTheme.bodyLarge,
               children: [
                 TextSpan(
                   text: 'Please update to continue for the best experience.',
                   style: Theme.of(context).textTheme.bodyMedium,
                 ),
               ],
             ),
           ),
         ),
         actions: [
           FilledButton(
             onPressed: () async {
               HapticFeedback.mediumImpact().ignore();
               ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
               await Future<void>.delayed(Durations.medium1);
               updateCheckController.update();
             },
             child: const Text(
               'Update Now',
             ),
           ),
           TextButton(
             onPressed: () {
               HapticFeedback.mediumImpact().ignore();
               ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
               updateCheckController.ignoreUpdate();
             },
             child: const Text(
               'Later',
             ),
           ),
         ],
       );
}
