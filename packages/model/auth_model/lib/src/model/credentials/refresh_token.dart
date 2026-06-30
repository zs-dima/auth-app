/// Opaque refresh token. A zero-cost [extension type] over [String] (no `implements String`) so it
/// is NOT interchangeable with arbitrary strings — preventing an access/refresh token mix-up at the
/// type level. Unwrap with [value] at the transport boundary (proto field / JSON).
extension type const RefreshToken(String value) {}
