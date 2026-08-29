import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

void main() {
  group('Input widgets accessibility', () {
    Widget wrap(Widget child) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(padding: const .all(16), child: child),
        ),
      ),
    );

    testWidgets('LabelField meets text contrast and tap target guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(const LabelField(title: 'Title', label: 'Label value', helperText: 'Helper')),
      );

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('AppTextFormField meets text contrast and tap target guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(
          const AppTextFormField(
            true,
            decoration: InputDecoration(labelText: 'Email', helperText: 'Your e-mail'),
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  });
}
