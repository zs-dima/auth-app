// Conditional export: the browser implementation reads localStorage, the native one returns null.
export 'service_override_vm.dart'
    // ignore: uri_does_not_exist
    if (dart.library.js_interop) 'service_override_js.dart';
