import 'package:auth_app/app/initialization/model/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef AppDependenciesErrorBuilderCallback = Widget Function(Object error, StackTrace? stackTrace);

/// {@template dependencies_scope}
/// DependenciesScope widget.
/// {@endtemplate}
class DependenciesScope extends StatelessWidget {
  /// {@macro dependencies_scope}
  const DependenciesScope({
    required this.initialization,
    required this.splashScreen,
    required this.child,
    this.errorBuilder,
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
      switch (context.getElementForInheritedWidgetOfExactType<_DependenciesScopeInherited>()?.widget) {
        final _DependenciesScopeInherited inheritedDependencies => inheritedDependencies.dependencies,
        _ => null,
      };

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
        'Out of scope, not found inherited widget a DependenciesScope of the exact type',
        'out_of_scope',
      );

  /// Initialization of the dependencies.
  final Future<Dependencies> initialization;

  /// Splash screen widget.
  final Widget splashScreen;

  /// Error widget.
  final AppDependenciesErrorBuilderCallback? errorBuilder;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) => FutureBuilder<Dependencies>(
        future: initialization,
        builder: (_, snapshot) => switch ((snapshot.data, snapshot.error, snapshot.stackTrace)) {
          (final Dependencies dependencies, null, null) => _DependenciesScopeInherited(
              dependencies: dependencies,
              child: child,
            ),
          (_, final Object error, final StackTrace? stackTrace) =>
            errorBuilder?.call(error, stackTrace) ?? ErrorWidget(error),
          _ => splashScreen,
        },
      );
}

/// {@template inherited_dependencies}
/// InheritedDependencies widget.
/// {@endtemplate}
class _DependenciesScopeInherited extends InheritedWidget {
  /// {@macro inherited_dependencies}
  const _DependenciesScopeInherited({
    required this.dependencies,
    required super.child,
  });

  final Dependencies dependencies;

  @override
  bool updateShouldNotify(covariant _DependenciesScopeInherited oldWidget) => false;
}
