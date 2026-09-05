import 'package:auth_app/_core/model/dependencies.dart';
import 'package:auth_app/initialization/init_step.dart';
import 'package:auth_app/initialization/initialize_dependencies.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InitStep runner', () {
    test('dispose order is the exact reverse of create order', () async {
      final log = <String>[];
      final steps = <InitStep>[
        InitStep('a', (_) => log.add('create:a'), dispose: (_) => log.add('dispose:a')),
        InitStep('b', (_) => log.add('create:b')), // no resources — no dispose
        InitStep('c', (_) async => log.add('create:c'), dispose: (_) async => log.add('dispose:c')),
      ];

      final dependencies = await composeDependencies(steps);
      await disposeSteps(steps, dependencies);

      expect(log, ['create:a', 'create:b', 'create:c', 'dispose:c', 'dispose:a']);
    });

    test('a failing step disposes the completed steps — and itself — in reverse', () async {
      // The failed step's own dispose runs too: its create may have partially built resources.
      final log = <String>[];
      final steps = <InitStep>[
        InitStep('a', (_) => log.add('create:a'), dispose: (_) => log.add('dispose:a')),
        InitStep(
          'boom',
          (_) => throw StateError('boom'),
          dispose: (_) => log.add('dispose:boom'),
        ),
        InitStep('never', (_) => log.add('create:never'), dispose: (_) => log.add('dispose:never')),
      ];

      await expectLater(composeDependencies(steps), throwsA(anything));

      expect(log, ['create:a', 'dispose:boom', 'dispose:a'], reason: 'steps after the failure never run');
    });

    test('a dispose touching an unset late field is silently skipped; later disposes still run', () async {
      final log = <String>[];
      final steps = <InitStep>[
        InitStep('a', (_) {}, dispose: (_) => log.add('dispose:a')),
        // Reads a late field its create never set — the partial-teardown case.
        InitStep('unbuilt', (_) {}, dispose: (dependencies) => dependencies.database.close()),
      ];

      await disposeSteps(steps, Dependencies());

      expect(log, ['dispose:a'], reason: 'the LateInitializationError must not stop the teardown');
    });

    test('a throwing dispose does not skip the disposes after it', () async {
      final log = <String>[];
      final steps = <InitStep>[
        InitStep('a', (_) {}, dispose: (_) => log.add('dispose:a')),
        InitStep('faulty', (_) {}, dispose: (_) => throw Exception('teardown fault')),
      ];

      await disposeSteps(steps, Dependencies());

      expect(log, ['dispose:a']);
    });
  });

  group('production step list', () {
    test('step names are unique', () {
      final names = initializationSteps.map((s) => s.name).toList();
      expect(names.toSet().length, names.length);
    });

    test('every resource-owning step keeps its dispose (drift guard)', () {
      // The defect class C2 exists for: a resource created in a step whose teardown quietly
      // disappears. If a step here legitimately stops owning a resource, update this set in the
      // same change that removes the dispose.
      const mustDispose = {
        'Error tracking',
        'Connect to database',
        // The journal sink and the `package:logging` bridge: a composition that ran and was
        // abandoned must take both off the pipeline, or an orphan sink keeps writing into a
        // database the next step closes.
        'Collect logs',
        'Connect client factory',
        'Prepare notifications',
        'Prepare updates check',
        'Prepare authentication handler',
        'Prepare authentication repository',
        'Prepare external HTTP client',
        'Prepare authentication controller',
      };
      final byName = {for (final s in initializationSteps) s.name: s};
      for (final name in mustDispose) {
        expect(byName, contains(name));
        expect(byName[name]!.dispose, isNotNull, reason: '"$name" creates resources — it must dispose them');
      }
    });
  });
}
