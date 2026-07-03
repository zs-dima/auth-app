/// Opaque refresh token: a zero-cost extension type over [String] (no `implements String`), so it
/// is not interchangeable with arbitrary strings. Unwrap with [value] at the transport boundary.
///
/// NOTE: an extension type cannot override `Object.toString` — `'$refreshToken'` prints the raw
/// secret; every composite holding one must mask it (as `AccessCredentials.toString` does).
extension type const RefreshToken(String value) {}
