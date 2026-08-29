import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

void main() {
  group('WindowSize', () {
    WindowSize at(double width) => .new(Size(width, 800));

    test('classifies M3 breakpoint boundaries', () {
      expect(at(0).isCompact, isTrue);
      expect(at(599).isCompact, isTrue);
      expect(at(600).isMedium, isTrue);
      expect(at(839).isMedium, isTrue);
      expect(at(840).isExpanded, isTrue);
      expect(at(1199).isExpanded, isTrue);
      expect(at(1200).isLarge, isTrue);
      expect(at(1599).isLarge, isTrue);
      expect(at(1600).isExtraLarge, isTrue);
    });

    test('orLarger helpers are cumulative', () {
      expect(at(599).isMediumOrLarger, isFalse);
      expect(at(600).isMediumOrLarger, isTrue);
      expect(at(840).isExpandedOrLarger, isTrue);
      expect(at(1200).isLargeOrLarger, isTrue);
      expect(at(1600).isLargeOrLarger, isTrue);
    });

    test('map is exhaustive over the size classes', () {
      String name(double width) => at(width).map(
        compact: () => 'compact',
        medium: () => 'medium',
        expanded: () => 'expanded',
        large: () => 'large',
        extraLarge: () => 'extraLarge',
      );
      expect(name(599), equals('compact'));
      expect(name(600), equals('medium'));
      expect(name(840), equals('expanded'));
      expect(name(1200), equals('large'));
      expect(name(1600), equals('extraLarge'));
    });

    test('maybeMap falls back to orElse for omitted handlers', () {
      expect(at(840).maybeMap(orElse: () => 'other', compact: () => 'compact'), equals('other'));
      expect(at(599).maybeMap(orElse: () => 'other', compact: () => 'compact'), equals('compact'));
    });

    test('mapWithLowerFallback cascades down to the nearest smaller handler', () {
      String name(double width) => at(width).mapWithLowerFallback(
        compact: () => 'compact',
        medium: () => 'medium',
      );
      final medium = equals('medium');
      expect(name(599), equals('compact'));
      expect(name(600), medium);
      // No expanded/large/extraLarge handlers — medium is the nearest smaller one.
      expect(name(840), medium);
      expect(name(1200), medium);
      expect(name(1600), medium);
    });

    testWidgets('WindowSizeScope.of reflects the window size', (tester) async {
      late WindowSize windowSize;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(900, 600)),
          child: WindowSizeScope(
            child: Builder(
              builder: (context) {
                windowSize = WindowSizeScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(windowSize.isExpanded, isTrue);
    });
  });
}
