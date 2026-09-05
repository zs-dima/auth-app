import 'package:web/web.dart' as web;

/// Reads a service-address override out of `localStorage`.
///
/// What it is for: pointing a web build at another backend without rebuilding.
/// A `flutter build web` bakes its addresses in, so testing a staging front-end
/// against a local API used to mean a full rebuild — with this, it is one line
/// in the browser console:
///
/// ```js
/// localStorage.setItem('auth_app.api_base_url', 'http://localhost:8080');
/// location.reload();
/// ```
///
/// The caller gates this on the environment: a production build ignores it
/// entirely, so a hostile page that plants a key cannot redirect a real user's
/// credentials to a server of its choosing.
String? $serviceOverride(String key) {
  try {
    final value = web.window.localStorage.getItem(key)?.trim();
    return value == null || value.isEmpty ? null : value;
  } on Object {
    // Storage can be denied outright (a private window, a blocked third-party
    // context). A developer convenience must never be the thing that stops the
    // app from starting.
    return null;
  }
}
