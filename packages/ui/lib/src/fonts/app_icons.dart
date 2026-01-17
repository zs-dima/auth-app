import 'package:flutter/widgets.dart';

@staticIconProvider
abstract final class AppIcons {
  static const _kFontFamily = 'icons';
  static const String _kFontPkg = 'ui'; // current package name, null for app

  static const IconData apple = IconData(0xF0D5, fontFamily: _kFontFamily, fontPackage: _kFontPkg);
  static const IconData windows = IconData(0x1014F, fontFamily: _kFontFamily, fontPackage: _kFontPkg);
  static const IconData windowsOutline = IconData(0xF33B, fontFamily: _kFontFamily, fontPackage: _kFontPkg);
  static const IconData google = IconData(0xF653, fontFamily: _kFontFamily, fontPackage: _kFontPkg);
  static const IconData sun = IconData(0xF03D, fontFamily: _kFontFamily, fontPackage: _kFontPkg);

  const AppIcons._();
}
