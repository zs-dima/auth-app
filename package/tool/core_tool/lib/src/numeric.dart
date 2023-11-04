extension BoolX on bool? {
  // ignore: prefer-named-boolean-parameters
  bool whenEmpty(bool value) => this == null ? value : this!;
}

extension NumX<T extends num> on T? {
  bool get isNullOrEmpty => this == null || this == 0;

  T whenEmpty(T value) => isNullOrEmpty ? value : this!;
}
