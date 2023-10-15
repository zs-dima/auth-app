import 'dart:async';

/// {@template preferences_entry}
/// [PreferencesEntryAsync] describes a single entry in the preferences.
/// This is used to get and set values in the preferences.
/// {@endtemplate}
abstract base class PreferencesEntryAsync<T extends Object> {
  /// {@macro preferences_entry}
  const PreferencesEntryAsync();

  /// Obtain the value of the entry from the preferences.
  FutureOr<T?> get();

  /// Set the value of the entry in the preferences.
  FutureOr<void> set(T value);

  /// Remove the entry from the preferences.
  FutureOr<void> remove();

  /// Set the value of the entry in the preferences if the value is not null.
  FutureOr<void> setIfNullRemove(T? value) => value == null ? remove() : set(value);
}
