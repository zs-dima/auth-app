/// gRPC metadata key carrying the bearer token. gRPC metadata keys are lowercase ASCII — kept as a
/// plain constant so this platform-agnostic package never reaches for `dart:io`'s `HttpHeaders`
/// (which breaks the web build — see A1). Single source of truth for the gRPC auth metadata key,
/// shared by the authentication middleware and the manual attach in `signOut`.
///
/// The metadata *value* is built from the token via `AccessToken.authorizationHeaderValue` — the
/// single transport-neutral source of truth, shared with the REST middleware.
const kGrpcAuthorizationKey = 'authorization';
