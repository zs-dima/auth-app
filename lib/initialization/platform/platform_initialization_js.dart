// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

//import 'package:flutter_web_plugins/url_strategy.dart';

extension type const $JSWindow._(JSObject _) implements JSObject {
  /// Update loading progress.
  external void updateLoadingProgress(int progress, String text);

  /// Removes the loading indicator.
  external void removeLoadingIndicator();
}

@JS('window')
external $JSWindow get window;

Future<void> $platformInitialization() async {
  // TODO Navigator(reportsRouteUpdateToEngine: false,

  //setUrlStrategy(NoHistoryUrlStrategy());
  //setUrlStrategy(const HashUrlStrategy());
  usePathUrlStrategy();

  BrowserContextMenu.disableContextMenu().ignore();
}

void $updateLoadingProgress({int progress = 100, String text = ''}) => window.updateLoadingProgress(progress, text);

void $removeLoadingWidget() => window.removeLoadingIndicator();

/* class NoHistoryUrlStrategy extends PathUrlStrategy {
  @override
  void pushState(Object? state, String title, String url) =>
      replaceState(state, title, url);
}
*/
