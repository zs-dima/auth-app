import 'dart:async';

import 'package:auth_app/_core/model/dependencies.dart';
import 'package:meta/meta.dart';

/// One app-initialization step: [create] builds its share of [Dependencies]; [dispose], when
/// given, tears down EXACTLY what [create] built.
///
/// Canon rule (app-line architecture): teardown is colocated with creation, and the dispose
/// mirror is DERIVED — the runner disposes the step list in reverse order — so the mirror cannot
/// drift from the steps by construction. The hand-written mirror this pattern replaces had
/// drifted to 5 disposed resources out of ~25 steps (leaking controllers, the update-check
/// timer, and the Sentry client); with colocation, adding a resource without its teardown is
/// visible in the same diff hunk that creates it.
@immutable
class InitStep {
  const InitStep(this.name, this.create, {this.dispose});

  /// Progress label; unique within the step list.
  final String name;

  /// Builds this step's dependencies.
  final FutureOr<void> Function(Dependencies dependencies) create;

  /// Tears down what [create] built; `null` when the step allocates nothing that outlives it.
  final FutureOr<void> Function(Dependencies dependencies)? dispose;
}
