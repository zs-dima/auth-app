import 'package:auth_app/authentication/widget/layout/auth_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The chassis under every auth screen: centred when the form fits, scrollable when it does not.
///
/// It used to be `SafeArea > Center > LayoutBuilder > SingleChildScrollView` — insets OUTSIDE the
/// scrollable, which is what `AGENTS.md` forbids: the viewport, and with it the scrollbar and the
/// overscroll, stopped short of the screen edge. The sliver form has to keep both behaviours, and
/// a short window is exactly where a fill-remaining sliver goes wrong if the padding is on the
/// wrong side of it.
void main() {
  Future<void> pump(WidgetTester tester, {required Size size, required double contentHeight}) async {
    tester.view
      ..devicePixelRatio = 1.0
      ..physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: AuthLayout(
          child: SizedBox(
            height: contentHeight,
            width: 200,
            child: Container(color: const Color(0xFF2196F3)),
          ),
        ),
      ),
    );
  }

  group('AuthLayout', () {
    testWidgets('centres a form that fits, without scrolling', (tester) async {
      await pump(tester, size: const Size(400, 800), contentHeight: 200);

      expect(tester.takeException(), isNull);
      final position = tester.widget<Scrollable>(find.byType(Scrollable)).controller?.position;
      expect(position?.maxScrollExtent ?? 0, isZero, reason: 'nothing to scroll when the form fits');
      final box = tester.getRect(find.byType(SizedBox).last);
      expect(box.center.dy, closeTo(400, 1), reason: 'centred in the window');
    });

    testWidgets('scrolls a form taller than the window instead of overflowing', (tester) async {
      await pump(tester, size: const Size(400, 300), contentHeight: 900);

      expect(tester.takeException(), isNull, reason: 'a tall form must scroll, not overflow');

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pump();

      expect(tester.getRect(find.byType(SizedBox).last).top, lessThan(0), reason: 'the content moved under the top');
    });

    testWidgets('the horizontal inset is inside the scrollable, so the viewport spans the window', (tester) async {
      await pump(tester, size: const Size(1200, 800), contentHeight: 200);

      // The width cap (620) is applied as sliver padding; the viewport itself must still be the
      // full window, or the scrollbar and the drag region stop short of the edge.
      expect(tester.getSize(find.byType(CustomScrollView)).width, equals(1200));
    });
  });
}
