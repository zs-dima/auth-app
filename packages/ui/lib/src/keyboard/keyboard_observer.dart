import 'package:ui/src/keyboard/platform/keyboard_observer_interface.dart';
import 'package:ui/src/keyboard/platform/keyboard_observer_vm.dart'
    // ignore: uri_does_not_exist
    if (dart.library.js_interop) 'package:ui/src/keyboard/platform/keyboard_observer_js.dart';

sealed class KeyboardObserver {
  const KeyboardObserver._();
  static IKeyboardObserver? _keyboardObserver;
  static IKeyboardObserver get instance => _keyboardObserver ??= $getKeyboardObserver();
}
