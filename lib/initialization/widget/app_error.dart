import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
import 'package:flutter/material.dart';

/// {@template app_error}
/// AppError widget
/// {@endtemplate}
class AppError extends StatefulWidget {
  /// {@macro app_error}
  const AppError({super.key, this.error, this.stackTrace, this.onRetry});

  /// Error
  final Object? error;

  /// Shown below the error in debug builds only.
  final StackTrace? stackTrace;

  /// Re-runs the whole initialization sequence (composition is not resumable mid-step).
  final VoidCallback? onRetry;

  @override
  State<AppError> createState() => _AppErrorState();
}

class _AppErrorState extends State<AppError> {
  bool _retrying = false;

  void _retry() {
    if (_retrying) return;
    setState(() => _retrying = true);
    widget.onRetry?.call();
  }

  @override
  void didUpdateWidget(AppError oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A failed retry mounts a fresh AppError over this one; the State is reused,
    // so re-arm the Retry button instead of spinning forever.
    _retrying = false;
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'App Error',
    theme: View.of(context).platformDispatcher.platformBrightness == .dark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true),
    home: Scaffold(
      // Fill the viewport, then scroll — the framework's own shape, and the one that keeps the
      // scroll region the size of the screen. `SafeArea > Center` around a scroll view shrank the
      // viewport to the content's height, so on a short phone with a long stack trace there was
      // nothing to scroll at all, and the scrollbar never reached the edge. The insets go INSIDE
      // (`SliverSafeArea`, `SliverPadding`); the bottom one goes inside the fill, because an
      // after-padding is not counted in `precedingScrollExtent` and would make the fill taller
      // than the viewport for ever.
      body: CustomScrollView(
        slivers: <Widget>[
          SliverSafeArea(
            bottom: false,
            sliver: SliverPadding(
              padding: const .all(8.0),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: SafeArea(
                  top: false,
                  left: false,
                  right: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: .min,
                      children: [
                        Text(
                          // The raw error only outside release: initialization fails before localization
                          // loads, so there is no sentence to translate — and an exception's own words are
                          // for whoever is debugging, not for the user staring at a stopped app.
                          kReleaseMode ? 'Something went wrong' : widget.error?.toString() ?? 'Something went wrong',
                          textScaler: .noScaling,
                        ),
                        if (widget.onRetry != null) ...[
                          const SizedBox(height: 16),
                          // English on purpose: localization is not initialized when this screen shows.
                          if (_retrying)
                            const CircularProgressIndicator()
                          else
                            FilledButton.icon(
                              onPressed: _retry,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                        ],
                        if (kDebugMode && widget.stackTrace != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            widget.stackTrace!.toString(),
                            textScaler: .noScaling,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    // The framework's own helper, not a hand-built `MediaQueryData`: `MediaQuery.of` here
    // subscribed to every metric of a screen that has no reason to rebuild at all.
    builder: (context, child) => MediaQuery.withNoTextScaling(child: child!),
  );
}
