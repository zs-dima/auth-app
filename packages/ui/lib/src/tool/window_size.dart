import 'package:flutter/widgets.dart';

/// Material 3 window size class over a [Size], as a zero-cost extension type.
///
/// Breakpoints (https://m3.material.io/foundations/layout/applying-layout/window-size-classes):
/// compact < 600, medium 600–839, expanded 840–1199, large 1200–1599, extraLarge ≥ 1600.
///
/// Complements [ScreenSize] (`screen.dart`) with the M3 grid and cascading
/// [map]/[maybeMap]/[mapWithLowerFallback] selectors.
extension type const WindowSize(Size _size) implements Size {
  /// Window size from the nearest [WindowSizeScope], falling back to [MediaQuery.sizeOf].
  static WindowSize of(BuildContext context) => WindowSizeScope.of(context);

  static const double _medium = 600;
  static const double _expanded = 840;
  static const double _large = 1200;
  static const double _extraLarge = 1600;

  /// Width < 600 — phones in portrait.
  bool get isCompact => width < _medium;

  /// 600 ≤ width < 840 — tablets in portrait, foldables.
  bool get isMedium => width >= _medium && width < _expanded;

  /// Width ≥ 600.
  bool get isMediumOrLarger => width >= _medium;

  /// 840 ≤ width < 1200 — tablets in landscape, small desktops.
  bool get isExpanded => width >= _expanded && width < _large;

  /// Width ≥ 840.
  bool get isExpandedOrLarger => width >= _expanded;

  /// 1200 ≤ width < 1600 — desktops.
  bool get isLarge => width >= _large && width < _extraLarge;

  /// Width ≥ 1200.
  bool get isLargeOrLarger => width >= _large;

  /// Width ≥ 1600 — wide desktops, ultra-wide.
  bool get isExtraLarge => width >= _extraLarge;

  /// Exhaustively maps the current size class.
  T map<T>({
    required T Function() compact,
    required T Function() medium,
    required T Function() expanded,
    required T Function() large,
    required T Function() extraLarge,
  }) {
    if (isCompact) return compact();
    if (isMedium) return medium();
    if (isExpanded) return expanded();
    if (isLarge) return large();
    return extraLarge();
  }

  /// Maps the current size class, or returns `orElse` when its handler is omitted.
  T maybeMap<T>({
    required T Function() orElse,
    T Function()? compact,
    T Function()? medium,
    T Function()? expanded,
    T Function()? large,
    T Function()? extraLarge,
  }) => map(
    compact: compact ?? orElse,
    medium: medium ?? orElse,
    expanded: expanded ?? orElse,
    large: large ?? orElse,
    extraLarge: extraLarge ?? orElse,
  );

  /// Maps the current size class, cascading down to the nearest smaller provided
  /// handler — `compact` is the guaranteed floor.
  ///
  /// E.g. on an `expanded` window with only `compact` and `medium` given, `medium` wins.
  T mapWithLowerFallback<T>({
    required T Function() compact,
    T Function()? medium,
    T Function()? expanded,
    T Function()? large,
    T Function()? extraLarge,
  }) => map(
    compact: compact,
    medium: medium ?? compact,
    expanded: expanded ?? medium ?? compact,
    large: large ?? expanded ?? medium ?? compact,
    extraLarge: extraLarge ?? large ?? expanded ?? medium ?? compact,
  );
}

/// Provides the current [WindowSize] to descendants via [WindowSizeScope.of].
///
/// Note: dependents rebuild on every window size change (pixel-level, as MediaQuery does),
/// not only when the size class flips.
class WindowSizeScope extends StatelessWidget {
  /// Creates a [WindowSizeScope].
  const WindowSizeScope({required this.child, super.key});

  /// Window size from the nearest scope, falling back to [MediaQuery.sizeOf].
  static WindowSize of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_InheritedWindowSize>()?.windowSize ??
      .new(MediaQuery.sizeOf(context));

  /// The subtree that can look the window size up.
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      _InheritedWindowSize(windowSize: WindowSize(MediaQuery.sizeOf(context)), child: child);
}

class _InheritedWindowSize extends InheritedWidget {
  const _InheritedWindowSize({required this.windowSize, required super.child});

  final WindowSize windowSize;

  @override
  bool updateShouldNotify(_InheritedWindowSize oldWidget) => windowSize != oldWidget.windowSize;
}
