import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  /// {@template scope_maybe_of}
  /// Obtain the nearest widget of the given type T,
  /// which must be the type of a concrete [InheritedWidget] subclass,
  /// and register this build context with that widget such that
  /// when that widget changes (or a new widget of that type is introduced,
  /// or the widget goes away), this build context is rebuilt so that it can
  /// obtain new values from that widget.
  /// {@endtemplate}
  T? scopeMaybeOf<T extends InheritedWidget>({
    bool listen = true,
  }) =>
      listen ? dependOnInheritedWidgetOfExactType<T>() : getInheritedWidgetOfExactType<T>();

  /// {@macro scope_maybe_of}
  /// If the widget is not found, an exception will be thrown.
  T scopeOf<T extends InheritedWidget>({
    bool listen = true,
  }) =>
      scopeMaybeOf<T>(listen: listen) ?? _notFoundInheritedWidgetOfExactType<T>();

  /// Maybe inherit specific aspect from [InheritedModel].
  T? maybeInheritFrom<A extends Object, T extends InheritedModel<A>>(
    A? aspect,
  ) =>
      InheritedModel.inheritFrom<T>(this, aspect: aspect);

  /// Inherit specific aspect from [InheritedModel].
  T inheritFrom<A extends Object, T extends InheritedModel<A>>({A? aspect}) =>
      InheritedModel.inheritFrom<T>(this, aspect: aspect) ??
      (throw ArgumentError(
        'Out of scope, not found inherited model a $T of the exact type',
        'out_of_scope',
      ));

  /// {@template not_found_inherited_widget_of_exact_type}
  /// This throws an exception when there is
  /// no inherited widget of the exact type.
  /// {@endtemplate}
  static Never _notFoundInheritedWidgetOfExactType<T extends InheritedWidget>() => throw ArgumentError(
        'Out of scope, not found inherited widget a $T of the exact type',
        'out_of_scope',
      );

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
}
