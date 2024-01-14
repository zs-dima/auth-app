import 'package:auth_app/app/app.dart';
import 'package:flutter/material.dart';

extension DependenciesScopeX on BuildContext {
  /// {@macro dependencies}
  Dependencies get dependencies => DependenciesScope.of(this);
}

/// {@template dependencies_scope}
/// DependenciesScope widget.
/// {@endtemplate}
class DependenciesScope extends InheritedWidget {
  /// {@macro dependencies_scope}
  const DependenciesScope({
    required this.dependencies,
    required super.child,
    super.key,
  });

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// e.g. `DependenciesScope.of(context)`
  static Dependencies of(BuildContext context) => maybeOf(context) ?? _notFoundInheritedWidgetOfExactType();

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `DependenciesScope.maybeOf(context)`.
  static Dependencies? maybeOf(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<DependenciesScope>()?.widget as DependenciesScope?)
          ?.dependencies;

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
        'Out of scope, not found inherited widget a DependenciesScope of the exact type',
        'out_of_scope',
      );

  final Dependencies dependencies;

  @override
  bool updateShouldNotify(DependenciesScope oldWidget) => false;
}
