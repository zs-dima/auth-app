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
           builder: (_, updateState, __) {
             final isApplying = updateState is ApplyingUpdateState;
             return Text.rich(
               TextSpan(
                 text: 'A new version (v${updateState.version}) of the app is available.\n',
                 style: Theme.of(context).textTheme.bodyLarge,
                 children: [
                   TextSpan(
                     text: isApplying
                         ? 'Applying the update and reloading the page...'
                         : 'Please update to continue for the best experience.',
                     style: Theme.of(context).textTheme.bodyMedium,
                   ),
                 ],
               ),
             );
           },
         ),
         actions: [
           StateConsumer<UpdateCheckController, UpdateCheckState>(
             controller: updateCheckController,
             builder: (_, updateState, __) {
               final isApplying = updateState is ApplyingUpdateState;
               return FilledButton(
                 onPressed: isApplying
                     ? null
                     : () {
                         HapticFeedback.mediumImpact().ignore();
                         updateCheckController.update();
                       },
                 child: Text(
                   isApplying ? 'Updating...' : 'Update Now',
                 ),
               );
             },
           ),
           StateConsumer<UpdateCheckController, UpdateCheckState>(
             controller: updateCheckController,
             builder: (_, updateState, __) {
               final isApplying = updateState is ApplyingUpdateState;
               return TextButton(
                 onPressed: isApplying
                     ? null
                     : () {
                         HapticFeedback.mediumImpact().ignore();
                         ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                         updateCheckController.ignoreUpdate();
                       },
                 child: const Text(
                   'Later',
                 ),
               );
             },
           ),
         ],
       );
}
