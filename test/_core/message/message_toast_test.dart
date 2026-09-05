import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_app/_core/message/extension/message_toast.dart';
import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:auth_app/_core/message/widget/message_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart' show AppTone;

import '../../helpers/pump_app.dart';

/// A failure as the pipeline hands it to the UI.
UiMessage _failure() => .new(
  tone: .alert,
  text: 'Не удалось сохранить',
  details: LogEvent(
    level: .error,
    body: 'Settings | save | failed',
    timestamp: DateTime.now().toUtc(),
    runId: 'run-under-test',
    meta: const <String, Object?>{'app.settings.key': 'theme'},
    error: const FormatException('bad payload'),
  ),
);

void main() {
  group('showUiMessage', () {
    Future<BuildContext> pumpHost(WidgetTester tester) async {
      late BuildContext hostContext;
      // A Scaffold, because ScaffoldMessenger refuses to show a bar with none registered — the
      // same reason the real app puts AppMessageScope inside the app's shell.
      await tester.pumpApp(
        Scaffold(
          body: Builder(
            builder: (context) {
              hostContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return hostContext;
    }

    testWidgets('the icon is drawn in the foreground colour, not the background one', (tester) async {
      final context = await pumpHost(tester);
      final scheme = Theme.of(context).colorScheme;

      context.showUiMessage(_failure());
      await tester.pump();

      final bar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(bar.backgroundColor, AppTone.alert.background(scheme));

      final icon = tester.widget<Icon>(find.descendant(of: find.byType(SnackBar), matching: find.byType(Icon)));
      expect(icon.color, AppTone.alert.foreground(scheme));
      // The defect this replaced: the warning sign was painted in `colorScheme.error` ON an
      // `error` background, so every failure toast carried an invisible icon.
      expect(icon.color, isNot(bar.backgroundColor));
    });

    testWidgets('the user reads the localized sentence, never the log body', (tester) async {
      final context = await pumpHost(tester);

      context.showUiMessage(_failure());
      await tester.pump();

      expect(find.text('Не удалось сохранить'), findsOneWidget);
      expect(find.text('Settings | save | failed'), findsNothing);
    });

    testWidgets('production shows the sentence and no way to see more', (tester) async {
      final context = await pumpHost(tester);

      context.showUiMessage(_failure());
      await tester.pumpAndSettle();

      expect(find.text('Details'), findsNothing);
    });

    testWidgets('Details opens the event behind the message', (tester) async {
      final context = await pumpHost(tester);

      context.showUiMessage(_failure(), withDetails: true);
      // Settled, not pumped once: the action is not hit-testable until the bar has slid in.
      await tester.pumpAndSettle();
      expect(find.text('Details'), findsOneWidget);

      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      expect(find.byType(MessageDetailsDialog), findsOneWidget);
      expect(find.textContaining('app.settings.key'), findsOneWidget);
      expect(find.textContaining('exception.type'), findsOneWidget);
    });
  });
}
