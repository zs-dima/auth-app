import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:ui/src/keyboard/platform/keyboard_observer_interface.dart';

IKeyboardObserver $getKeyboardObserver$Windows() => _KeyboardObserver$Windows();

@sealed
class _KeyboardObserver$Windows with _IsKeyPressed$Windows, ChangeNotifier implements IKeyboardObserver {
  @override
  bool get isControlPressed => isKeyPressed(.controlLeft) || isKeyPressed(.controlRight);

  @override
  bool get isShiftPressed => isKeyPressed(.shiftLeft) || isKeyPressed(.shiftRight);

  @override
  bool get isAltPressed => isKeyPressed(.altLeft) || isKeyPressed(.altRight);

  @override
  bool get isMetaPressed => isKeyPressed(.metaLeft) || isKeyPressed(.metaRight);
}

mixin _IsKeyPressed$Windows {
  /// Returns true if the given [LogicalKeyboardKey] is pressed.
  bool isKeyPressed(LogicalKeyboardKey key) => HardwareKeyboard.instance.logicalKeysPressed.contains(key);
}
