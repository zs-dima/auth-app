extension IterableX<F> on Iterable<F>? {
  bool get isNullOrEmpty => this == null || (this?.isEmpty ?? false);
}
