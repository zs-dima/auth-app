extension ObjectX<A> on A {
  B? maybeCast<B>() {
    final self = this;
    return self is B ? self : null;
  }
}

extension LetX<T> on T {
  /// The let extension wraps an object in a function,
  /// allowing you to perform operations and return the result.
  /// print(14.let((it) => it * 3)); // Outputs 42
  R let<R>(R Function(T it) callback) => callback(this);
}

extension IfNullX<T extends Object> on T? {
  /// The onNull extension provides a default value if the object is null,
  /// ensuring safe handling of nullable types.
  /// print(value.onNull(() => 14) * 3); // Outputs 42
  T onNull(T Function() callback) => this ?? callback();
}
