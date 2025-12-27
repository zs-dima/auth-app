import 'package:flutter/widgets.dart';

@staticIconProvider
abstract final class AppIcons {
  static const _kFontFamily = 'icons';
  static const String _kFontPkg = 'ui'; // current package name, null for app

  static const IconData add = IconData(0xe900, fontFamily: _kFontFamily, fontPackage: _kFontPkg);
  static const IconData question = IconData(0xe901, fontFamily: _kFontFamily, fontPackage: _kFontPkg);

  const AppIcons._();
}
