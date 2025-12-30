import 'package:auth_app/_core/widget/radial_progress_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:ui/ui.dart';

class InitializationSplashScreen extends StatelessWidget {
  const InitializationSplashScreen({required this.progress, super.key});

  final ValueListenable<({int progress, String message})> progress;

  @override
  Widget build(BuildContext context) {
    final theme = View.of(context).platformDispatcher.platformBrightness == Brightness.dark
        ? ThemeData.dark()
        : ThemeData.light();
    return Material(
      color: theme.primaryColor,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              RadialProgressIndicator(
                size: 128,
                child: ValueListenableBuilder<({String message, int progress})>(
                  valueListenable: progress,
                  builder: (context, value, _) => AppText.titleLarge(
                    '${value.progress}%',
                    height: 1,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Opacity(
                opacity: 0.25,
                child: ValueListenableBuilder<({String message, int progress})>(
                  valueListenable: progress,
                  builder: (context, value, _) => AppText.titleSmall(
                    value.message,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
