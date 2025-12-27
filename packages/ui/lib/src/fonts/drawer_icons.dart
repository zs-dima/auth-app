import 'package:flutter/widgets.dart';

@staticIconProvider
abstract final class DrawerIcons {
  static const _kFontFamily = 'drawer';
  static const String _kFontPkg = 'ui'; // current package name, null for app

  // static const IconData icon = IconData(0xe900, fontFamily: _kFontFamily, fontPackage: _kFontPkg);
  const DrawerIcons._();
}
