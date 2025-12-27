import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

// TODO Foldable device support
// TODO Move to AppTheme
/*
ui.FlutterView? _view;

@override
void didChangeDependencies() {
super.didChangeDependencies();
_view = View.maybeOf(context);
}

void handleSizeChange(Size size) {
final ui.Display? display = _view?.display;

final orientations = <DeviceOrientation>[];
orientations.addAll([
DeviceOrientation.portraitUp,
DeviceOrientation.portraitDown,
]);

bool isSmall = display.size.shortestSide / display.devicePixelRatio < 600;
if (!isSmall) {
orientations.addAll([
DeviceOrientation.landscapeLeft,
DeviceOrientation.landscapeRight,
]);
}
SystemChrome.setPreferredOrientations(orientations);

*/

/// {@macro screen_util}
extension ScreenUtilX on BuildContext {
  // TODO width < 600
  // TODO 600 ≤ width < 840
  // TODO 840 ≤ width < 1200
  // TODO 1200 ≤ width < 1600
  // https://m3.material.io/foundations/layout/applying-layout/window-size-classes

  /// Get current screen logical size representation
  ///
  /// phone   | <= 600 dp    | 4 column
  /// tablet  | 600..1023 dp | 8 column
  /// desktop | >= 1024 dp   | 12 column
  ScreenSize get screenSize => ScreenUtil.screenSizeOf(this);

  /// Portrait or Landscape
  // TODO Remove
  @Deprecated('Use MediaQuery.sizeOf(context) or LayoutBuilder for adaptive layout cases')
  Orientation get orientation => ScreenUtil.orientationOf(this);

  /// Evaluate the result of the first matching callback.
  ///
  /// phone   | <= 600 dp    | 4 column
  /// tablet  | 600..1023 dp | 8 column
  /// desktop | >= 1024 dp   | 12 column
  ScreenSizeWhenResult screenSizeWhen<ScreenSizeWhenResult>({
    required final ScreenSizeWhenResult Function() phone,
    required final ScreenSizeWhenResult Function() tablet,
    required final ScreenSizeWhenResult Function() desktop,
    required final ScreenSizeWhenResult Function() wideScreen,
  }) => ScreenUtil.screenSizeOf(this).when(phone: phone, tablet: tablet, desktop: desktop, wideScreen: wideScreen);

  /// The [screenSizeMaybeWhen] method is equivalent to [screenSizeWhen],
  /// but doesn't require all callbacks to be specified.
  ///
  /// On the other hand, it adds an extra [orElse] required parameter,
  /// for fallback behavior.
  ScreenSizeWhenResult screenSizeMaybeWhen<ScreenSizeWhenResult>({
    required final ScreenSizeWhenResult Function() orElse,
    final ScreenSizeWhenResult Function()? phone,
    final ScreenSizeWhenResult Function()? tablet,
    final ScreenSizeWhenResult Function()? desktop,
  }) => ScreenUtil.screenSizeOf(this).maybeWhen(phone: phone, tablet: tablet, desktop: desktop, orElse: orElse);
}

/// {@template screen_util}
/// Screen logical size representation
///
/// phone   | <= 600 dp    | 4 column
/// tablet  | 600..1023 dp | 8 column
/// desktop | >= 1024 dp   | 12 column
/// {@endtemplate}
abstract final class ScreenUtil {
  /// {@macro screen_util}
  static ScreenSize get screenSize {
    final view = ui.PlatformDispatcher.instance.implicitView;
    if (view == null) return ScreenSize.phone;
    final size = view.physicalSize ~/ view.devicePixelRatio;
    return _screenSizeFromSize(size);
  }

  /// Portrait or Landscape
  // TODO Remove
  @Deprecated('Use MediaQuery.sizeOf(context) or LayoutBuilder for adaptive layout cases')
  static Orientation get orientation {
    final view = ui.PlatformDispatcher.instance.implicitView;
    final size = view?.physicalSize;
    return size == null || size.height > size.width ? Orientation.portrait : Orientation.landscape;
  }

  static ScreenSize from(Size size) => _screenSizeFromSize(size);

  /// {@macro screen_util}
  static ScreenSize screenSizeOf(final BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return _screenSizeFromSize(size);
  }

  /// Portrait or Landscape
  // TODO Remove
  @Deprecated('Use MediaQuery.sizeOf(context) or LayoutBuilder for adaptive layout cases')
  static Orientation orientationOf(BuildContext context) => MediaQuery.orientationOf(context);

  static ScreenSize _screenSizeFromSize(final Size size) => switch (size.width) {
    <= 600 => ScreenSize.phone,
    <= 1024 => ScreenSize.tablet,
    <= 1600 => ScreenSize.desktop,
    _ => ScreenSize.wideScreen,
  };
}

/// {@macro screen_util}
@immutable
sealed class ScreenSize {
  /// Phone
  static const phone = ScreenSize$Phone();

  /// Tablet
  static const tablet = ScreenSize$Tablet();

  /// Large desktop
  static const desktop = ScreenSize$Desktop();

  /// Wide screen
  static const wideScreen = ScreenSize$WideScreen();

  /// {@macro screen_util}
  @literal
  const ScreenSize._(this.representation, this.min, this.max);

  /// Minimum width in logical pixels
  final double min;

  /// Maximum width in logical pixels
  final double max;

  /// String representation
  final String representation;

  /// Is phone
  abstract final bool isPhone;

  /// Is tablet
  abstract final bool isTablet;

  /// Is desktop
  abstract final bool isDesktop;

  /// Is wide screen
  abstract final bool isWideScreen;

  /// Evaluate the result of the first matching callback.
  ///
  /// phone   | <= 600 dp    | 4 column
  /// tablet  | 600..1023 dp | 8 column
  /// desktop | >= 1024 dp   | 12 column
  ScreenSizeWhenResult when<ScreenSizeWhenResult>({
    required final ScreenSizeWhenResult Function() phone,
    required final ScreenSizeWhenResult Function() tablet,
    required final ScreenSizeWhenResult Function() desktop,
    required final ScreenSizeWhenResult Function() wideScreen,
  });

  /// The [maybeWhen] method is equivalent to [when],
  /// but doesn't require all callbacks to be specified.
  ///
  /// On the other hand, it adds an extra [orElse] required parameter,
  /// for fallback behavior.
  ScreenSizeWhenResult maybeWhen<ScreenSizeWhenResult>({
    required final ScreenSizeWhenResult Function() orElse,
    final ScreenSizeWhenResult Function()? phone,
    final ScreenSizeWhenResult Function()? tablet,
    final ScreenSizeWhenResult Function()? desktop,
    final ScreenSizeWhenResult Function()? wideScreen,
  }) => when<ScreenSizeWhenResult>(
    phone: phone ?? orElse,
    tablet: tablet ?? orElse,
    desktop: desktop ?? orElse,
    wideScreen: wideScreen ?? orElse,
  );

  @override
  String toString() => representation;
}

/// {@macro screen_util}
final class ScreenSize$Phone extends ScreenSize {
  /// {@macro screen_util}
  @literal
  const ScreenSize$Phone() : super._('Phone', 0, 599);

  @override
  bool get isPhone => true;

  @override
  bool get isTablet => false;

  @override
  bool get isDesktop => false;

  @override
  bool get isWideScreen => false;

  @override
  int get hashCode => 0;

  @override
  ScreenSizeWhenResult when<ScreenSizeWhenResult>({
    required final ScreenSizeWhenResult Function() phone,
    required final ScreenSizeWhenResult Function() tablet,
    required final ScreenSizeWhenResult Function() desktop,
    required final ScreenSizeWhenResult Function() wideScreen,
  }) => phone();

  @override
  bool operator ==(final Object other) => identical(other, this) || other is ScreenSize$Phone;
}

/// {@macro screen_util}
final class ScreenSize$Tablet extends ScreenSize {
  /// {@macro screen_util}
  @literal
  const ScreenSize$Tablet() : super._('Tablet', 600, 1023);

  @override
  bool get isPhone => false;

  @override
  bool get isTablet => true;

  @override
  bool get isDesktop => false;

  @override
  bool get isWideScreen => false;

  @override
  int get hashCode => 1;

  @override
  ScreenSizeWhenResult when<ScreenSizeWhenResult>({
    required final ScreenSizeWhenResult Function() phone,
    required final ScreenSizeWhenResult Function() tablet,
    required final ScreenSizeWhenResult Function() desktop,
    required final ScreenSizeWhenResult Function() wideScreen,
  }) => tablet();

  @override
  bool operator ==(final Object other) => identical(other, this) || other is ScreenSize$Tablet;
}

/// {@macro screen_util}
final class ScreenSize$Desktop extends ScreenSize {
  /// {@macro screen_util}
  @literal
  const ScreenSize$Desktop() : super._('Desktop', 1024, 1599);

  @override
  bool get isPhone => false;

  @override
  bool get isTablet => false;

  @override
  bool get isDesktop => true;

  @override
  bool get isWideScreen => false;

  @override
  int get hashCode => 2;

  @override
  ScreenSizeWhenResult when<ScreenSizeWhenResult>({
    required final ScreenSizeWhenResult Function() phone,
    required final ScreenSizeWhenResult Function() tablet,
    required final ScreenSizeWhenResult Function() desktop,
    required final ScreenSizeWhenResult Function() wideScreen,
  }) => desktop();

  @override
  bool operator ==(final Object other) => identical(other, this) || other is ScreenSize$Desktop;
}

/// {@macro screen_util}
final class ScreenSize$WideScreen extends ScreenSize {
  /// {@macro screen_util}
  @literal
  const ScreenSize$WideScreen() : super._('WideScreen', 1600, double.infinity);

  @override
  bool get isPhone => false;

  @override
  bool get isTablet => false;

  @override
  bool get isDesktop => false;

  @override
  bool get isWideScreen => true;

  @override
  int get hashCode => 3;

  @override
  ScreenSizeWhenResult when<ScreenSizeWhenResult>({
    required final ScreenSizeWhenResult Function() phone,
    required final ScreenSizeWhenResult Function() tablet,
    required final ScreenSizeWhenResult Function() desktop,
    required final ScreenSizeWhenResult Function() wideScreen,
  }) => wideScreen();

  @override
  bool operator ==(final Object other) => identical(other, this) || other is ScreenSize$WideScreen;
}
