import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump_app.dart';
import 'test_dependencies.dart';

void main() {
  group('Test harness', () {
    test('TestDependencies fails fast with a named error on an unassigned field', () {
      final dependencies = TestDependencies();
      expect(
        () => dependencies.usersController,
        throwsA(
          isA<Error>().having((e) => e.toString(), 'message', contains('usersController')),
        ),
      );
    });

    testWidgets('pumpApp provides dependencies and localization to the tree', (tester) async {
      final dependencies = TestDependencies();
      late BuildContext capturedContext;

      await tester.pumpApp(
        Builder(
          builder: (context) {
            capturedContext = context;
            return const Text('ok');
          },
        ),
        dependencies: dependencies,
      );

      expect(find.text('ok'), findsOneWidget);
      expect(InheritedDependencies.of(capturedContext), same(dependencies));
      // Localization.of throws when the delegate has not loaded — reaching here means it did.
      expect(() => Localization.of(capturedContext), returnsNormally);
    });
  });
}
