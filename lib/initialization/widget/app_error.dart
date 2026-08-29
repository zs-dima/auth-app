import 'package:flutter/foundation.dart' show kDebugMode;
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const .all(8.0),
            child: Column(
              mainAxisSize: .min,
              children: [
                Text(
                  // ErrorUtil.formatMessage(error)
                  widget.error?.toString() ?? 'Something went wrong',
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
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: .noScaling),
      child: child!,
    ),
  );
}
