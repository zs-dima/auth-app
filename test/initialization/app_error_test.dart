import 'package:auth_app/initialization/widget/app_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppError', () {
    testWidgets('shows the error text without a retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(const AppError(error: 'boom'));

      expect(find.text('boom'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('Retry invokes the callback once and guards against double taps', (tester) async {
      var retries = 0;
      await tester.pumpWidget(AppError(error: 'boom', onRetry: () => retries++));

      final retryButton = find.widgetWithText(FilledButton, 'Retry');
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pump();

      // The button is replaced by a progress indicator; a second tap is impossible.
      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(retries, equals(1));
    });

    testWidgets('a failed retry re-arms the Retry button on the next AppError mount', (tester) async {
      var retries = 0;
      void onRetry() => retries++;

      await tester.pumpWidget(AppError(error: 'boom', onRetry: onRetry));
      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // The retry fails again: main.dart runs runApp(AppError(...)) with a fresh widget,
      // but the State at the same tree position is reused.
      await tester.pumpWidget(AppError(error: 'boom again', onRetry: onRetry));

      expect(find.text('boom again'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
