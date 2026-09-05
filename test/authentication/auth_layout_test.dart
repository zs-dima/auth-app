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
    testWidgets('centres a form built the way the screens build one', (tester) async {
      // The shape every auth screen hands over: a `Column` at its DEFAULT `mainAxisSize.max`
      // (`signin_screen.dart` and its three siblings). It is the case the first version of this
      // layout got wrong — a max-size column fills whatever box it is given, so a `Center` around
      // it has no slack left and the form sat at the top of the window.
      tester.view
        ..devicePixelRatio = 1.0
        ..physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);
      const form = Key('form');
      await tester.pumpWidget(
        const MaterialApp(
          home: AuthLayout(
            child: Column(
              key: form,
              children: <Widget>[
                SizedBox(height: 50, width: 200, child: Placeholder()),
                SizedBox(height: 32),
                SizedBox(height: 50, width: 200, child: Placeholder()),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final rect = tester.getRect(find.byKey(form));
      expect(rect.height, closeTo(132, 1), reason: 'the column keeps its content height');
      expect(rect.center.dy, closeTo(400, 1), reason: 'and sits in the middle of the window');
    });

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

    testWidgets('a max-size column taller than the window scrolls, and starts at the top', (tester) async {
      // Same shape as the screens, but past the viewport: the fill sliver takes the column's
      // intrinsic height, so there is no slack to centre and the content simply scrolls.
      const form = Key('form');
      tester.view
        ..devicePixelRatio = 1.0
        ..physicalSize = const Size(400, 300);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(
          home: AuthLayout(
            child: Column(
              key: form,
              children: <Widget>[
                SizedBox(height: 400, child: Placeholder()),
                SizedBox(height: 400, child: Placeholder()),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull, reason: 'a tall form scrolls rather than overflowing');
      final rect = tester.getRect(find.byKey(form));
      expect(rect.height, closeTo(800, 1), reason: 'the column keeps its content height');
      expect(rect.top, closeTo(0, 1), reason: 'and starts at the top: there is nothing to centre');

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pump();

      // Re-read after the drag: the point is that it MOVED, so the earlier value cannot be reused.
      // ignore: use-existing-variable
      expect(tester.getRect(find.byKey(form)).top, lessThan(0));
    });

    testWidgets('the horizontal inset is inside the scrollable, so the viewport spans the window', (tester) async {
      await pump(tester, size: const Size(1200, 800), contentHeight: 200);

      // The width cap (620) is applied as sliver padding; the viewport itself must still be the
      // full window, or the scrollbar and the drag region stop short of the edge.
      expect(tester.getSize(find.byType(CustomScrollView)).width, equals(1200));
    });
  });
}
