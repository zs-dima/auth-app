import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

/// What [LabelWidget]'s constant shape must NOT cost.
///
/// The widget stopped changing its tree on a runtime value: an empty label used to return the
/// child bare, and a "wrap only on a large screen" helper used to add a level. A child that moves
/// depth is REBUILT rather than updated, and a text field losing its element loses its focus, its
/// selection and the IME's composing region. The price is that the field now always sits in a
/// `Flexible`, whose loose fit hands the child UNBOUNDED height where the bare child inherited the
/// parent's constraints. These pin both halves of that trade.
void main() {
  Widget host({required Widget child, double? height}) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 320, height: height, child: child),
      ),
    ),
  );

  group('LabelWidget', () {
    testWidgets('expands: true fills the bounded space, label or no label', (tester) async {
      const probe = Key('probe');

      Future<double> heightOf({required String label, required bool expands}) async {
        await tester.pumpWidget(
          host(
            height: 240,
            child: LabelWidget(
              label: label,
              expands: expands,
              child: const SizedBox(key: probe),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        return tester.getSize(find.byKey(probe)).height;
      }

      for (final label in <String>['', 'Notes']) {
        final loose = await heightOf(label: label, expands: false);
        final tight = await heightOf(label: label, expands: true);

        expect(tight, greaterThan(loose), reason: 'a tight Flexible is the Expanded this replaced ($label)');
        expect(tight, lessThanOrEqualTo(240));
      }
    });

    testWidgets('expands: false leaves the child its own height', (tester) async {
      await tester.pumpWidget(
        host(
          height: 240,
          child: const LabelWidget(
            label: 'Notes',
            child: SizedBox(height: 42, child: Placeholder()),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(Placeholder)).height, equals(42));
    });

    testWidgets('the label is a slot: the field keeps its element when the label arrives', (tester) async {
      // The regression the whole design exists to prevent — a field rebuilt mid-typing.
      // A bare field on purpose: the subject is its ELEMENT surviving the label, and a controller
      // would make the state observable through something other than the element.
      Widget labelled(String label) => host(
        // ignore: avoid-missing-controller
        child: LabelWidget(label: label, child: const TextField()),
      );
      EditableTextState fieldState() => tester.state<EditableTextState>(find.byType(EditableText));

      await tester.pumpWidget(labelled(''));
      final before = fieldState();

      await tester.pumpWidget(labelled('Now labelled'));

      // Reading it again IS the assertion: same call, and it must return the same object.
      // ignore: use-existing-variable
      expect(fieldState(), same(before));
      expect(find.text('Now labelled'), findsOneWidget);
    });

    testWidgets('an empty label takes no vertical space', (tester) async {
      Future<double> heightWith(String label) async {
        await tester.pumpWidget(
          host(
            child: LabelWidget(label: label, child: const SizedBox(height: 42)),
          ),
        );
        return tester.getSize(find.byType(LabelWidget)).height;
      }

      final bare = await heightWith('');
      final labelled = await heightWith('Notes');

      expect(bare, equals(42), reason: 'Visibility keeps the slot without occupying it');
      expect(labelled, greaterThan(bare));
    });
  });
}
