import 'package:flutter/material.dart';

extension DialogX on BuildContext {
  /// Ensure that pop calls are correctly aligned with the appropriate navigator,
  /// preventing wrong and unexpected behavior.
  void popDialog([Object? result]) {
    final state = Navigator.maybeOf(this, rootNavigator: true);
    if (state == null || !state.mounted) return;
    state.maybePop(result);
  }

  /// Pop all dialogs and bottom sheets.
  void popDialogs() {
    final state = Navigator.maybeOf(this, rootNavigator: true);
    if (state == null || !state.mounted) return;
    state.popUntil((route) => route is! RawDialogRoute<Object?> && route is! ModalBottomSheetRoute<Object?>);
  }
}
