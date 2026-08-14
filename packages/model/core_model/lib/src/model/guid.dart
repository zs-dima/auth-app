typedef Guid = String;

extension GuidX on Guid {
  static Guid get empty => '';

  /// The nil UUID (RFC 9562 §5.9) — all 128 bits zero. The sentinel the backend sends for
  /// "no id"; [empty] is the client-side equivalent. Const, so it works in const constructors.
  static const Guid nil = '00000000-0000-0000-0000-000000000000';
}
