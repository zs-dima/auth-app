import 'package:bloc/bloc.dart';

typedef BlocWhereStateCallback<State> = bool Function(State state);

extension BlocX<Event, State> on Bloc<Event, State> {
  /// This transformer is a shorthand for Stream.where followed by Stream.cast.
  ///
  /// [State]'s that do not match [T] are filtered out,
  ///  the resulting Stream will be of Type [T].
  Stream<T> whereState<T extends Object?>() => stream.where((state) => state is T).cast<T>();

  /// Filter with whereState<T>() and after that
  /// skips [State]'s if they are equal to the previous data event.
  ///
  /// [State]'s that do not match [T] are filtered out,
  ///  the resulting Stream will be of Type [T].
  Stream<T> whereUnique<T extends Object?>() => whereState<T>().distinct();

  /// This transformer leaves only the necessary states with downcast to [T]
  ///
  /// [State]'s that do not match [T] are filtered out,
  ///  the resulting Stream will be of Type [T].
  Stream<T> whereStates<T extends Object?>(BlocWhereStateCallback<State> filter) =>
      stream.where(filter).where((state) => state is T).cast<T>();

  /// Filter with whereStates<T>() and after that
  /// skips [State]'s if they are equal to the previous data event.
  /// Downcast states to [T]
  ///
  /// [State]'s that do not match [T] are filtered out,
  ///  the resulting Stream will be of Type [T].
  Stream<T> whereUniques<T extends Object?>(
    BlocWhereStateCallback<State> filter,
  ) =>
      whereStates<T>(filter).distinct();
}
