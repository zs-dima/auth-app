// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_interop';

import 'package:http/browser_client.dart' as browser_client;
import 'package:http/http.dart' as http;

/// JavaScript interop for accessing window.location.origin.
extension type const _JSLocation._(JSObject _) implements JSObject {
  /// The origin of the current window location.
  external String get origin;
}

/// JavaScript interop for accessing window.location.
extension type const _JSWindow._(JSObject _) implements JSObject {
  /// The location object of the current window.
  external _JSLocation get location;
}

/// Access to the global window object.
@JS('window')
external _JSWindow get _window;

/// Returns the current window origin for the HTTP client.
/// On web platforms, this returns the current window's location origin.
///
/// Example: `https://example.com`
String $getOrigin() => _window.location.origin;

/// Creates an HTTP client optimized for browser platforms.
///
/// Uses [BrowserClient] which leverages XMLHttpRequest/Fetch API
/// and supports credentials for cross-origin requests.
http.Client $createHttpClient() => browser_client.BrowserClient()
  // Enable credentials (cookies) for cross-origin requests.
  // This is necessary for authentication to work properly with APIs.
  ..withCredentials = true;
