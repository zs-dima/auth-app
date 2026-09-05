import 'package:auth_app/_core/localization/localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

// A global function on purpose, and it cannot be anything else: this IS the value of
// `ErrorWidget.builder`, whose type is `Widget Function(FlutterErrorDetails)`. A widget class
// would still have to be wrapped in exactly this function to be assignable.
// ignore: avoid-returning-widgets
/// What takes the place of a widget that threw while building.
///
/// The framework default is the red error box with the exception text on it.
/// That is exactly right in debug and exactly wrong in release: it turns one
/// broken list tile into a screen that looks like a crash, and it prints
/// internal detail onto the user's screen — and into their screenshots.
///
/// In release the box becomes a neutral placeholder, so the rest of the screen
/// still works. The failure itself is not swallowed: `FlutterError.onError` has
/// already recorded it with its stack.
Widget buildAppErrorWidget(FlutterErrorDetails details) =>
    kDebugMode ? ErrorWidget(details.exception) : const ReleaseErrorBox();

/// The neutral placeholder a release build shows in place of a widget that threw.
///
/// Public so a test can pump it: `buildAppErrorWidget` takes the debug branch under `flutter
/// test`, and the branch worth pinning is the other one.
@visibleForTesting
class ReleaseErrorBox extends StatelessWidget {
  /// {@macro release_error_box}
  const ReleaseErrorBox({super.key});

  @override
  Widget build(BuildContext context) {
    // `Theme.of` falls back to a default theme with no ancestor, so it is safe even above
    // MaterialApp. `Directionality` has no such fallback, which is one reason this box carries no
    // text; the other is that a user has nothing to do with an exception's words.
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      // The loaded bucket, not a hardcoded string: this is a user-facing surface, and a screen
      // reader is the one place where the words are all there is. English only before the first
      // frame, which is also the only time this box has nothing to replace.
      label: Localization.currentErrors?.somethingWentWrong ?? 'Content unavailable',
      // LimitedBox, not SizedBox: an ErrorWidget replaces a widget wherever it was, including
      // inside a Row or a ListView where one axis is unbounded. Its maximum applies only there,
      // so the box still fills the space it was given when the space is bounded.
      child: LimitedBox(
        maxWidth: 160,
        maxHeight: 80,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            border: .all(color: scheme.outlineVariant),
            borderRadius: .circular(4),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
