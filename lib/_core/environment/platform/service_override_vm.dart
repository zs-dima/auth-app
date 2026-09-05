/// The address override is a browser-only affordance (see the js implementation).
///
/// On native there is nothing to override from: a build carries its addresses,
/// and a developer who wants different ones rebuilds with a different
/// `--dart-define-from-file`.
String? $serviceOverride(String key) => null;
