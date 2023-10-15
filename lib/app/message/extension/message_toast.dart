import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  void showError(String message) {
    final theme = Theme.of(this);

    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        backgroundColor: theme.colorScheme.error,
        content: Row(
          children: [
            Expanded(
              child: Text(message),
            ),
            Icon(
              Icons.warning,
              color: theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  void showInfo(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(message),
      ),
    );
  }

  void showProgress(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(message),
            ),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
