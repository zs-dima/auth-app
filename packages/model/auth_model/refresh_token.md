# Refresh-token flow — the complete specification

**Markers** (grep anchors used throughout):

- **INVARIANT (id)** — a rule that MUST hold. Where `id` is a short tag (A2, A3, A12, A22, A26, A27,  F1, F2, F6) it matches the tag used verbatim in code comments and/or test names, so `grep -rn "A2"` round-trips between this doc, the code, and the tests. IDs labeled "review-ID" (A19, F3) come from review notes and may exist in code only as the symbol they describe.
- **DELIBERATE** — a decision that may look wrong, redundant, or incomplete but is intentional. Do not "fix" it without owner sign-off (§15).
- **DEFERRED** — a known gap, consciously postponed. Do not re-report it as a finding; see §16 for revisit triggers.
- **SERVER-CONTRACT** — an expectation the client places on the backend and cannot verify locally (§12.2).
- **RECOMMENDED** — an improvement this spec endorses; implement only as an explicitly scoped task.

RFC 2119 keywords (MUST / MUST NOT / SHOULD / MAY) are used in their normative sense.

**Conventions**: file paths are repo-root-relative in backticks. Code is referenced by symbol name, never by line number — line numbers rot, symbols and tags are rep-stable. ASCII diagrams are illustrative; the numbered step lists are normative.

---

## 1. Scope and reading guide

This document specifies the complete lifecycle of access/refresh tokens in this solution: the token
model, both transport middlewares, the repository that owns all token state, persistence, the wire
contract, the failure policy, concurrency guards, telemetry rules, and the hardening roadmap.

It deliberately spans two packages and the app layer: token types and middleware contracts live in `packages/model/auth_model`, the HTTP pipeline in `packages/model/http_client`, and the stateful half (single-flight, persistence, logout) in the app at `lib/authentication/data/authentication_repository.dart`. That split is architectural (§3.2); the spec covers the whole and MUST NOT be split per package or relocated.

Sibling docs this file does not duplicate:

- `packages/model/auth_model/README.md` — package layering; why a "model" package hosts the Connect RPC transport.
- `lib/_core/api/README.md` — which middleware lives in packages vs the app (transport-generic vs observability).
- `web/README.md` — web storage limits, multi-tab caveats, the CDN/CSP HTTP-header checklist.

Maintenance rule: a PR that changes any behavior described here MUST update this document in the same PR and refresh the "Last verified against" line.

## 2. Threat model and security goals

Threats considered (RFC 9700 attacker model applied to this app):

| Threat                            | Vector here                                                                                                    | Primary controls                                                                                                            |
| --------------------------------- | -------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Stolen refresh token              | device theft, OS backup extraction, XSS on web (localStorage)                                                  | secure storage + CSP (§10), SERVER-CONTRACT rotation + reuse detection (§12.2), Sessions API revocation (§11.5)             |
| Leaked access token               | logs, telemetry, URLs, object dumps                                                                            | short TTL via JWT `exp` (§4.1), redaction at source types (§13), POST-only token RPCs (§12.1), header/query scrubbing (§13) |
| Replay of a rotated refresh token | attacker replays an old RT                                                                                     | SERVER-CONTRACT reuse detection revokes the token family (§12.2); client treats rejection as definitive logout (§8)         |
| Token exfiltration via `toString` | controller-state observer serializes state into Sentry span data — a real past incident here, fixed 2026-07-02 | redacting `toString` on `AccessToken` / `AccessCredentials` (§4, §13)                                                       |
| Session resurrection / torn state | refresh racing logout or sign-in                                                                               | mutex + session epoch + write ordering (§9)                                                                                 |
| Spurious-logout DoS               | treating flow errors or transient faults as session death                                                      | `sessionEndingPaths` narrowing (§7.4), transient-vs-definitive policy (§8), 403 is never logout (§7.5)                      |

Security goals, in priority order:

1. The refresh token is presented to exactly one endpoint (`RefreshTokens`) — plus the deliberate
   `ListSessions` exception (§12.1) — and never appears in URLs, logs, traces, or serialized state.
2. Access tokens are short-lived; expiry is read from the JWT `exp` claim only.
3. A definitive server rejection of the refresh token ends the session immediately and durably. Nothing
   else ends it (except explicit sign-out).
4. No transient fault — network, 5xx, timeout, storage hiccup — ever logs the user out.
5. Every session-state mutation is serialized and race-guarded; a logout can never be overtaken or
   resurrected.
6. Fail closed: a session that cannot be durably persisted is not a session.

## 3. System map

### 3.1 Components

| Component                                                                                  | Location                                                                                              | Responsibility                                                                                           |
| ------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `AccessToken`                                                                              | `packages/model/auth_model/lib/src/model/credentials/access_token.dart`                               | JWT wrapper: `exp`-based expiry, `expiresSoon`, redacting `toString`, `authorizationHeaderValue`         |
| `RefreshToken`                                                                             | `packages/model/auth_model/lib/src/model/credentials/refresh_token.dart`                              | zero-cost `extension type` over `String`; type-level separation from access tokens                       |
| `AccessCredentials`                                                                        | `packages/model/auth_model/lib/src/model/credentials/access_credentials.dart`                         | access + refresh + scopes; the persisted JSON blob; masks both secrets in `toString`                     |
| `ConnectAuthenticationClient`                                                                 | `packages/model/auth_model/lib/src/connect/connect_authentication_client.dart`                              | all auth RPCs; refresh-outcome classification; `mapRefreshResponse`                                      |
| `ConnectAuthenticationMiddleware`, `kAuthServicePublicPaths`, `kAuthServiceRefreshTokensPath` | `packages/model/auth_model/lib/src/connect/middlewares/connect_authentication_middleware.dart`              | attach + 401→refresh→retry-once (unary); repair-without-replay (streaming)                               |
| `HttpAuthenticationMiddleware`                                                             | `packages/model/auth_model/lib/src/http/middlewares/http_authentication_middleware.dart`              | exact HTTP mirror of the Connect middleware; **standby, currently unwired** (§15)                        |
| `BearerAuthenticationMiddleware`                                                           | `packages/model/http_client/lib/src/middlewares/bearer_authentication_middleware.dart`                | minimal attach-only middleware, no refresh/retry — a different tool (§15); do not confuse with the above |
| `ApiClient`, `kNoRetryContextKey`, `ApiClientRequest.canBeRetried`                         | `packages/model/http_client/lib/src/api_client.dart`                                                  | HTTP onion pipeline, body-replayability rules, session-cancel binding                                    |
| `CredentialsRejectedException`                                                             | `packages/model/auth_model/lib/src/api/auth_exceptions.dart`                                          | the single "definitive refresh rejection" signal                                                         |
| `RequestSessionEndedException`                                                             | `packages/model/auth_model/lib/src/api/auth_exceptions.dart`                                          | typed A27 throw: a request that outlived its session fails without touching the current one              |
| `RpcException` family                                                                     | `packages/model/auth_model/lib/src/api/rpc_exceptions.dart`                                         | typed transport errors (`$Authentication`, `$Network`, `$Request`, `$Server`, `$Cancelled`)              |
| `AuthenticationHandler` / `IAuthenticationHandler`                                         | `packages/model/auth_model/lib/src/client/authentication_handler.dart`                                | the single transport-agnostic auth-state bus (A26)                                                       |
| `AuthenticationRepository`                                                                 | `lib/authentication/data/authentication_repository.dart`                                              | ALL token state: single-flight, generation dedup, proactive refresh, persistence, session epoch, logout  |
| `SettingsRepository`, `AppSecurePreferencesDao`                                            | `lib/settings/data/settings_repository.dart`, `lib/settings/data/dao/app_secure_preferences_dao.dart` | persistence: `credentials` blob (secure storage), `user_id` (plain prefs)                                |
| Composition root                                                                           | `lib/initialization/initialize_dependencies.dart`                                                     | the only sanctioned wiring of all of the above                                                           |
| Resume hook                                                                                | `lib/_core/app_tree.dart`                                                                             | proactive refresh on `AppLifecycleState.resumed`                                                         |

### 3.2 The architectural invariant

**INVARIANT (architecture):** the middlewares are stateless attach + retry-once wrappers. ALL stateful
logic — the single-flight mutex, token-generation dedup, proactive expiry check, persistence, session
epoch, logout — lives in `AuthenticationRepository` behind three callbacks. A middleware instance is only
safe when its callbacks are wired to a repository (or an equivalent single-flight owner).

Wiring `refreshCredentials` to a naive "just call the refresh RPC" lambda re-introduces the rotation
stampede: N parallel 401s → N refresh calls → with server-side rotation, N−1 of them present an
already-rotated token, which can trip reuse detection and revoke the whole session. The composition in
`lib/initialization/initialize_dependencies.dart` is the reference wiring.

### 3.3 Middleware callback contract

| Callback                              | Returns credentials                                                                                                                      | Returns `null`                                                                                                                                                                            | Throws                                                                                                                                                                                                                                                              |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `getToken()`                          | current credentials; the implementation MUST proactively refresh when `expiresSoon` (single-flight)                                      | definitively no session → middleware calls `onAuthError()` and fails the call fast (RPC: `ConnectException(Code.unauthenticated, …)`; HTTP: `ApiClientException$Authentication(code: 'no_credentials')`) | transient resolution failure (e.g. a secure-storage hiccup) → propagates as-is, **no logout** — **INVARIANT (A3)**                                                                                                                                                  |
| `refreshCredentials(usedAccessToken)` | rotated credentials — or the current ones when `usedAccessToken` is already stale within the same session (another wave refreshed; §7.2) | definitive rejection; the repository has already ended the session; middleware calls `onAuthError()` and rethrows the original auth error                                                 | transient failure → propagates, **no logout**; a later request retries. A typed throw (A27, `RequestSessionEndedException` from `auth_model`) likewise fails a request whose session ended before the refresh ran — no `onAuthError`, the current session untouched |
| `onAuthError()`                       | fire-and-forget logout signal into the bus (A26); MUST be idempotent and MUST NOT throw                                                  | —                                                                                                                                                                                         | —                                                                                                                                                                                                                                                                   |

`unauthenticatedPaths` — exact-match path allowlist that skips attach and refresh-retry (§7.4).
`sessionEndingPaths` — the subset whose auth-code rejection is definitive for the stored session; wired
to exactly `{kAuthServiceRefreshTokensPath}`.

**INVARIANT (A3 — null vs throw):** `null` means "definitively no session"; a thrown error means
"transient, try again later". Collapsing a transient error into `null` (e.g. `catch → return null`)
converts every storage or network hiccup into a forced logout. The `getToken` wrapper in
`lib/initialization/initialize_dependencies.dart` exists precisely to rethrow instead of swallowing.

### 3.4 Pipeline order

From `lib/initialization/initialize_dependencies.dart`, outermost → innermost:

```
ConnectLoggerMiddleware → ConnectMetadataMiddleware → ConnectSentryMiddleware → ConnectRetryMiddleware
    → ConnectAuthenticationMiddleware → wire
```

- `ConnectRetryMiddleware` retries transient RPC codes only and **excludes UNAUTHENTICATED** — 401
  recovery belongs exclusively to the auth middleware. Two layers reacting to 401 would multiply refresh
  attempts and retries.
- Auth is innermost so the token is attached per attempt and the 401→refresh→retry-once loop runs
  closest to the wire.
- Logger is outermost (one log line per logical call); the Sentry span wraps Retry so it covers all
  attempts.
- The same `ConnectAuthenticationMiddleware` instance serves both the auth-service and users-service
  clients — one single-flight domain per repository.
- The external HTTP `ApiClient` (S3 presigned uploads) deliberately carries **no** auth middleware and no
  first-party `X-*` metadata — a presigned URL is self-authenticated and first-party headers must not
  leak to third parties — but it IS bound to `sessionCancelToken`, so logout aborts in-flight uploads.

## 4. Token model and validation policy

### 4.1 `AccessToken`

- Fields: `type` (scheme, default `Bearer`), `token` (raw JWT), `expiry` (UTC `DateTime`; a non-UTC value
  throws `ArgumentError` even in release builds).
- `AccessToken.fromJwtToken(String)` — **DELIBERATE: decode-only.** Splits the JWT, base64url-decodes the
  payload, and reads **only** the integer `exp` claim (seconds → UTC). No signature verification, no
  `nbf`/`iat`/`aud`/`iss` checks: a public client holds no server signing secret, so client-side
  verification would be security theater; the server is the sole validator. Every structural problem
  throws a typed `FormatException`, which the refresh path maps to a **definitive** rejection —
  **INVARIANT (A12)** — so a malformed token can never loop forever as a "transient" error.
- `expiresSoon` ≡ `now(UTC) > expiry − 30 s` — the proactive-refresh window and the only clock-skew
  margin in the system. `hasExpired` is exact (no leeway). Consequence: client clock skew larger than
  30 s makes the proactive check misfire in either direction; the reactive 401 path (§7.2) is the
  designed safety net. This is why the retry-once-after-refresh MUST NOT be removed even where proactive
  refresh "should have" prevented the 401.
- `authorizationHeaderValue` ≡ `'<type> <token>'` — the single transport-neutral Authorization value.
  The RPC header value (key `kAuthorizationHeader` = `authorization`,
  `packages/model/auth_model/lib/src/connect/authorization.dart`) and the HTTP `Authorization` header
  are both built from this one getter. A future scheme change (e.g. DPoP) happens here, once.
- `toString()` prints `data=***` (§13). Value equality over `(type, token, expiry)` feeds the
  `setCredentials` dedup guard.

### 4.2 `RefreshToken`

- `extension type const RefreshToken(String value)` — a zero-cost compile-time wrapper that does NOT
  implement `String`, so an access token cannot be passed where a refresh token is expected and vice
  versa.
- **INVARIANT (refresh-token-masking):** a Dart extension type CANNOT override `Object.toString`, so
  `'$refreshToken'` prints the raw secret. Every composite that holds a `RefreshToken` MUST mask it in
  its own `toString`, as `AccessCredentials` does (`refreshToken=***`). This is the number-one
  accidental-leak vector when introducing new secret-bearing types.

### 4.3 `AccessCredentials`

`accessToken` + `refreshToken` + `scopes` (order-sensitive value equality). `toJson()`/`fromJson()`
round-trip the persisted blob (§10.1); `fromJson` tolerates a missing `scopes` list for older blobs.
`toString()` masks both secrets.

### 4.4 Why both tokens are persisted

**DELIBERATE:** the whole `AccessCredentials` blob (access + refresh) is persisted — not the
"refresh-only on disk, access in memory" pattern. Rationale: instant session rehydration at cold start
(`restore()` emits before any network round-trip, §11.1) and a single atomic blob write (the F1/F2
ordering and self-healing guarantees cover exactly one key). Risk delta: zero on native platforms (both
patterns use the same secure store); on web both tokens sit in localStorage either way, where the refresh
token is the valuable secret and CSP is the mitigation (§10.2). Splitting the storage would buy nothing
here and would break restore-before-network.

### 4.5 Adjacent files

- `packages/model/auth_model/lib/src/model/credentials/jwt_token.dart` — a fully commented-out
  `JwtValidator` (HMAC-SHA256 verify). **DELIBERATE** scaffolding; keep (§15).
- `packages/model/auth_model/lib/src/model/credentials/token_tool.dart` — `TokenTool.generate`,
  a secure-random token generator. Not part of the refresh flow; out of scope for this spec.

## 5. Token lifecycle state machine

States as observable through `AuthenticationRepository.user` and the credentials condition:

```
UNAUTH ── sign-in / sign-up / MFA / OAuth / verification ─▶ AUTH(fresh)
AUTH(fresh)     ── time passes ────────────────────────────▶ AUTH(expiring)     [expiresSoon]
AUTH(expiring)  ── any request / resume / restore ─────────▶ REFRESHING         [mutex acquired]
REFRESHING      ── TokenPair, epoch unchanged ─────────────▶ AUTH(fresh)        [persisted, emitted]
REFRESHING      ── TokenPair, epoch changed ───────────────▶ UNAUTH             [tokens discarded (A2)]
REFRESHING      ── definitive rejection ───────────────────▶ UNAUTH             [storage cleared]
REFRESHING      ── transient error, proactive ─────────────▶ AUTH(expiring)     [current creds served]
REFRESHING      ── transient error, reactive ──────────────▶ AUTH(expiring)     [error rethrown to caller]
AUTH(any)       ── signOut() ──────────────────────────────▶ UNAUTH
AUTH(creds=null)── next proactive refresh attempt ─────────▶ UNAUTH             [definitive by construction]
UNAUTH          ── restore(): valid blob ──────────────────▶ AUTH(rehydrated) ─▶ proactive refresh
```

Notes:

- A stale `refreshCredentials` call whose token belongs to an ENDED session (A27, §7.2) throws without
  transitioning ANY state — neither the current session nor UNAUTH is touched; only that request fails.

- `AUTH(creds=null)` exists because `AuthenticatedUser.credentials` is nullable ("authenticated but
  credentials lost", preserved by the `AuthUser` JSON round-trip). `_doRefresh` treats missing/empty
  credentials as unrecoverable → definitive logout.
- `AUTH(expiring)` after a transient failure may in fact be past `expiry`; subsequent requests then take
  the reactive 401 path (§7.2). The session survives until a definitive rejection.
- There is exactly one REFRESHING at a time per repository instance — `_refreshingMutex` (A22).

## 6. Acquisition flows — single commit discipline

Five RPCs mint a `TokenPair`: `Authenticate`, `SignUp`, `VerifyMfa`, `ExchangeOAuthCode`, and
`ConfirmVerification` (auto-login after email/phone verification). All commit through
`AuthenticationRepository._handleAuthResult`:

1. The network call runs OUTSIDE the mutex — long I/O must not head-of-line-block refresh or logout.
2. On `AuthResultSuccess` the commit runs UNDER `_refreshingMutex`: `_persistSession(userId,
   credentials)` → set in-memory user → emit. Sign-in, refresh, and logout all serialize on the same
   lock; whichever lands last wins cleanly, and in-memory state never disagrees with storage.
3. **INVARIANT (fail-closed sign-in):** persist happens BEFORE the session is published. On a
   storage-write failure `_persistSession` rolls back any partial write (a `userId` without credentials
   must not survive for `restore()` to rebuild a mismatched session), best-effort revokes the just-issued
   server session (`SignOut` RPC), and rethrows. The app never runs half-signed-in.
4. Non-success results (`MFA_REQUIRED`, `FAILED`, `LOCKED`, `SUSPENDED`, `PENDING`) throw a typed
   `AuthenticationException` and MUST NOT touch any existing session state.
5. Every acquisition sends `installation_id` (UUID generated once per install) + `ClientInfo` (device
   id/name/type, client version) — the server binds the token family to a device session, visible later
   via `ListSessions` (§11.5).

6. Defensive issuance guards: a device-info read failure degrades to the unknown-device fallback and
   never blocks authentication (`DeviceInfo.instance` — `ClientInfo` is session labeling, not a
   credential); and an `AUTH_STATUS_SUCCESS` response missing the refresh token maps to a failed
   sign-in (converter throw into the A12 `FormatException` catch) — the RFC 6749 §6 omission rule
   applies only to REFRESH responses (§8), never to issuance.

Related, same layer: `ConnectAuthenticationClient.recoveryStart` swallows errors and always returns `true` —
OWASP anti-enumeration. Do not "fix" the swallowed exception there.

## 7. Refresh flows (normative)

### 7.1 Proactive refresh

1. Any authenticated call → middleware `getToken()` → `AuthenticationRepository.getAccessCredentials()`.
2. `getAccessCredentials()` runs `_doRefresh(force: false)` under `_refreshingMutex`.
3. `_doRefresh`: missing/empty credentials → definitive → `_logOutSession()` → `null`. Token not
   `expiresSoon` → return current credentials unchanged (the common cheap path — still serialized on the
   mutex; accepted cost, §15).
4. `expiresSoon` → snapshot `_sessionEpoch` → `RefreshTokens` RPC → classify per §8. On success:
   **await** `setUserId` + `setCredentials` (F1), re-check the epoch (A2), emit the rotated user, return
   the rotated credentials.

Proactive refresh also fires at cold-start `restore()` (§11.1) and on app resume
(`AppTree.didChangeAppLifecycleState`: `.resumed` + authenticated → `getAccessCredentials().ignore()` —
fire-and-forget; the single-flight mutex absorbs it; its failure never logs out).

### 7.2 Reactive refresh (unary RPC; replayable HTTP)

1. A call went out with access token `A`; the server answers `UNAUTHENTICATED` (RPC) / `401` (HTTP).
2. The middleware calls `refreshCredentials("A")` → repository, under the mutex:
   - **INVARIANT (A27 — session provenance):** `"A"` must have been minted in the CURRENT session
     (`_sessionAccessTokens`, seeded at sign-in/restore, extended per rotation, cleared by
     `_endSession`). A request that outlived its session — a sign-out, possibly followed by a new
     sign-in, raced its 401 — gets a typed `RequestSessionEndedException`: transient-shaped, so the
     stale request fails without `onAuthError` and is never retried under the new session's identity.
   - **Generation dedup:** if the currently stored access token ≠ `"A"`, another request of the same 401
     wave already refreshed → return the current credentials with zero network calls.
   - Otherwise `_doRefresh(force: true)` — a full refresh regardless of `expiresSoon`.
3. Rotated credentials returned → the middleware retries the original call **exactly once** with the
   fresh token.
4. Retry succeeded → done. Retry rejected with `UNAUTHENTICATED`/`401` again → `onAuthError()` + rethrow:
   a freshly rotated token being rejected means the session is broken server-side. MUST NOT loop
   refresh-retry.
5. `refreshCredentials` returned `null` (definitive; the repository has already logged out) →
   `onAuthError()` + rethrow the original auth error.
6. `refreshCredentials` threw (transient) → propagate WITHOUT `onAuthError` — a network blip during
   refresh never logs the user out (A3 policy).

### 7.3 Repair-without-replay

Applies to: RPC server-streaming calls; HTTP requests whose body cannot be replayed
(`MultipartRequest`, `StreamedRequest` → `ApiClientRequest.canBeRetried == false`); HTTP requests opted
out via `kNoRetryContextKey` (set automatically by `ApiClient.sendMultipart` / `postStream`).

**INVARIANT (repair-without-replay):** non-replayability and `kNoRetryContextKey` opt out of RESENDING
THE BODY — never of repairing the session. On a 401 these paths still run the same single-flight
`refreshCredentials`; afterwards the ORIGINAL 401 is rethrown (a consumed RPC request stream is never
re-invoked). The caller retries/resubscribes on its own terms and finds the rotated token already in
place. Logout rules are identical to §7.2 — definitive failures only.

### 7.4 Public paths

`kAuthServicePublicPaths` (single source of truth, co-located with the Connect middleware; asserted against
the generated stubs by `packages/model/auth_model/test/auth_public_paths_test.dart` — review-ID A19):

```
Authenticate, SignUp, SignOut, VerifyMfa, RecoveryStart, RecoveryConfirm,
RefreshTokens, ConfirmVerification, GetOAuthUrl, ExchangeOAuthCode
```

`RequestVerification` is **DELIBERATE**ly absent — per `api/proto/auth/v1/auth.proto` it is a resend for
an authenticated user and must carry the access token.

Public paths get no token attach and no refresh-retry. An auth-code error there (`UNAUTHENTICATED` /
`PERMISSION_DENIED`; HTTP 401/403) is a FLOW error — bad password, wrong MFA code, invalid recovery
token — surfaced to the caller.

**INVARIANT (sessionEndingPaths — review-ID F3):** a flow error on a public path MUST NOT end the
session. The single exception is `sessionEndingPaths`, wired to exactly
`{kAuthServiceRefreshTokensPath}`: an auth-code rejection of the refresh call itself is definitive
session death (§8). Widening `sessionEndingPaths` re-introduces the "bad password logs you out" bug.

Note: `SignOut` is a public path (no automatic attach); `ConnectAuthenticationClient.signOut` attaches the
CURRENT access token manually via `CallOptions` — logging out must never trigger a token refresh just to
say goodbye (§11.3).

### 7.5 403 / PERMISSION_DENIED on data paths

Authenticated-but-not-allowed. Surfaced as-is: no refresh, no retry, no logout. Logging out on 403 would
let any authorization gap terminate the session.

### 7.6 The refresh RPC in its own pipeline

`RefreshTokens` rides the same middleware stack as every call, as a public + session-ending path. On a
definitive rejection, logout can be signalled up to three times: the middleware `_public` handler fires
`onAuthError`; the repository maps `CredentialsRejectedException` → `_logOutSession()`; the outer unary
handler may fire `onAuthError` again. **DELIBERATE:** all paths converge idempotently — the bus
`distinct()`s events, `signOut` is epoch-guarded, the storage clears always run (best-effort, §11.3).
Over-signalling is accepted; under-signalling would be a bug.

### 7.7 Sequence diagrams (illustrative — the numbered steps above are normative)

Concurrent 401 wave — single-flight, generation dedup, retry-once:

```
R1 (sent w/ A)   R2 (sent w/ A)   Repository (mutex; stored A/RT1)      AuthService
 |                |                        |                                  |
 |<— UNAUTHENTICATED —— both requests were sent with token A ——————————————— |
 |                |<— UNAUTHENTICATED ———————————————————————————————————————|
 |— refreshCredentials("A") —————————————>|                                  |
 |                |— refreshCredentials("A") —> (queued on mutex)            |
 |                |                        |— RefreshTokens(RT1) ———————————>|
 |                |                        |<— TokenPair(B, RT2) ————————————|
 |                |                        | await persist(B,RT2); emit      |
 |<— credentials B ————————————————————————|  (stored: B/RT2)                |
 |                |                        | R2 enters mutex:                |
 |                |                        |   stored "B" != used "A"        |
 |                |<— credentials B (dedup, no network) —|                   |
 |— retry with B ——————————————————————————————————————————————————————————>|
 |                |— retry with B ——————————————————————————————————————————>|
 |<— OK ————————————————————————————————————————————————————————————————————|
 |                |<— OK ————————————————————————————————————————————————————|
```

Logout racing an in-flight refresh — epoch discard (A2):

```
caller                     Repository                              AuthService   storage
  |                         |                                          |            |
  |— getAccessCredentials —>| expiresSoon; snapshot epoch = 1          |            |
  |                         |— RefreshTokens(RT1) ————————————————————>|            |
  |— signOut() ————————————>| _endSession(): epoch = 2, cancel token   |            |
  |   (synchronous part;    |   signOut body queues on the mutex       |            |
  |    no mutex needed)     |                                          |            |
  |                         |<— TokenPair(B, RT2) ————————————————————— |           |
  |                         | epoch check: 2 != 1 → DISCARD B/RT2      |            |
  |                         | return null (no persist, no emit)        |            |
  |                         | mutex released → signOut body runs:      |            |
  |                         |   best-effort SignOut RPC ——————————————>|            |
  |                         |   emit unauthenticated                   |            |
  |                         |   await clear userId + credentials ——————————————————>X
```

## 8. Refresh-outcome classification

The transport→domain classification lives in `ConnectAuthenticationClient.refreshTokens`; the
domain→session policy lives in `AuthenticationRepository._doRefresh`.

| Outcome of `RefreshTokens`                                             | Class                                                                                        | Client action                                                                                                                                                                                                                    |
| ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `TokenPair` with new access + new refresh token                        | success                                                                                      | commit under the mutex: persist (awaited — F1) → epoch re-check (A2) → emit rotated user                                                                                                                                         |
| `TokenPair` with new access, EMPTY `refresh_token`                     | success — RFC 6749 §6 (server MAY omit)                                                      | **keep the previous refresh token** — `mapRefreshResponse`; persisting `""` would poison the next refresh (`min_len 1` → `INVALID_ARGUMENT`) into a spurious logout                                                              |
| Access token in the response fails JWT parsing                         | **definitive** — `FormatException` → `CredentialsRejectedException` (A12)                    | logout + clear storage; a structurally dead session must not loop as "transient"                                                                                                                                                 |
| `UNAUTHENTICATED` / `PERMISSION_DENIED` / `INVALID_ARGUMENT`           | **definitive** — `CredentialsRejectedException` (invalid / expired / revoked / reused token) | logout + clear storage                                                                                                                                                                                                           |
| `UNAVAILABLE`, `DEADLINE_EXCEEDED`, other codes, socket/timeout errors | transient — `RpcException.from` (`$Network` / `$Server` / …)                                | proactive: serve the current (still valid) credentials; reactive: rethrow — session intact, a later request retries                                                                                                              |
| Cancellation                                                           | transient family (`$Cancelled`)                                                              | as transient                                                                                                                                                                                                                     |
| Session epoch changed while awaiting the RPC or the persist            | stale generation (A2)                                                                        | discard the rotated tokens, return `null`; the logout's cleared state stands                                                                                                                                                     |
| Storage write throws during the persist step                           | transient (`on Object` in `_doRefresh`)                                                      | old credentials stay in memory and are served. Honest edge: the server may already have rotated, so the NEXT refresh can be definitively rejected → clean logout. Mitigated by the SERVER-CONTRACT rotation grace period (§12.2) |
| API returns `null` instead of throwing                                 | defensive definitive                                                                         | logout + clear (never trust a half-answer)                                                                                                                                                                                       |

**DELIBERATE:** `scopes` are dropped on rotation — `mapRefreshResponse` builds fresh credentials without
carrying the previous list. The server re-derives authorization from the token itself; the client does
not act on scopes today.

**DELIBERATE:** `IAuthenticationApi.refreshTokens(String accessToken, RefreshToken refreshToken)`
accepts the access token, but the Connect implementation does not send it — `RefreshTokensRequest` carries
only `refresh_token` (§12.1). The parameter remains for API symmetry and potential future transports.

## 9. Concurrency and race matrix

Single-writer rule: `_refreshingMutex` serializes refresh, the sign-in commit, logout clears, and every
`getAccessCredentials()` read. **INVARIANT (A22):** the mutex is instance-scoped (one lock per repository
instance, never `static`) so multi-account / impersonation / test instances don't head-of-line block each
other.

| Race                                                                          | Guard                                                                                                                                                                                                                                                                                                     | Anchor                                                 | Pinned by                                                                                                     |
| ----------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| N parallel requests hit an expiring token                                     | one refresh under the mutex; the rest read the committed result                                                                                                                                                                                                                                           | `_refreshingMutex`                                     | `test/authentication/authentication_repository_test.dart`                                                     |
| Concurrent 401 wave (many requests sent with token A)                         | generation dedup: stored token ≠ `usedAccessToken` → reuse, zero RPCs                                                                                                                                                                                                                                     | `refreshCredentials`                                   | same file                                                                                                     |
| Logout during an in-flight refresh                                            | **INVARIANT (A2):** `_endSession()` bumps `_sessionEpoch` SYNCHRONOUSLY before `signOut` awaits the mutex; `_doRefresh` snapshots the epoch and re-checks it BOTH after the RPC AND after the persist awaits; on mismatch the rotated tokens are discarded — no session resurrection                      | `_sessionEpoch`, `_endSession`, `_doRefresh`           | same file                                                                                                     |
| Refresh persist vs a queued logout's clears                                   | **INVARIANT (F1):** the persist is AWAITED under the mutex, so the queued logout's `setCredentials(null)` is ordered after it — storage always ends cleared. Disambiguation: the tag `F1` in `lib/_core/message/controller/app_message_controller_mixin.dart` belongs to a different review scope         | awaited `setUserId` / `setCredentials` in `_doRefresh` | same file                                                                                                     |
| Sign-in commit vs logout                                                      | both serialize on the same mutex; whichever lands last wins cleanly; memory never disagrees with storage                                                                                                                                                                                                  | `_handleAuthResult`                                    | same file                                                                                                     |
| `restore()` vs proactive refresh                                              | emit-then-correct (F6): the rehydrated user is emitted first, the refresh corrects state afterwards                                                                                                                                                                                                       | `restore()`                                            | same file                                                                                                     |
| Resume-refresh vs in-flight refresh                                           | single-flight absorbs both into the same mutex                                                                                                                                                                                                                                                            | `AppTree.didChangeAppLifecycleState`                   | by construction                                                                                               |
| Process death between server rotation and local persist                       | stale refresh token on disk at next start — unavoidable client-side                                                                                                                                                                                                                                       | none                                                   | SERVER-CONTRACT grace period (§12.2); otherwise the next refresh is definitively rejected → clean logout (§8) |
| Sign-out (± new sign-in) while a 401'd request awaits the refresh mutex       | **INVARIANT (A27 — session provenance):** `refreshCredentials` fails a `usedAccessToken` not minted in the current session with a typed, transient-shaped `RequestSessionEndedException` — the stale request is never retried with the new session's credentials, and the new session is never logged out | `_sessionAccessTokens`, `RequestSessionEndedException` | same file ("A27")                                                                                             |
| `terminate()` closes the user stream while a refresh/logout emit is in flight | close-safe emits: every publish site goes through `_emit`, which skips the stream add once the controller is closed                                                                                                                                                                                       | `_emit`                                                | same file ("terminate during an in-flight refresh")                                                           |
| Web: two tabs refresh the same RT simultaneously                              | none client-side — each tab has its own mutex; localStorage is shared                                                                                                                                                                                                                                     | **DEFERRED** → §16.1                                   | server grace period is the compensating control                                                               |

## 10. Persistence and platform storage

### 10.1 What is stored, and the write rules

Secure storage, single key `credentials` (`AppSecurePreferencesDao.credentials`), JSON blob:

```json
{
  "accessToken": { "type": "Bearer", "data": "<jwt>", "expiry": "2026-01-01T00:00:00.000Z" },
  "refreshToken": "<opaque-refresh-token>",
  "scopes": []
}
```

`user_id` lives separately in plaintext `shared_preferences` — **DELIBERATE:** a user id is not a
secret, and `restore()` needs it independently of the secure read.

Write rules:

- **INVARIANT (F2 — self-healing storage):** `SettingsRepository.setCredentials(null)` deletes
  unconditionally and MUST NOT decode the existing blob first — a corrupt blob must never be able to
  block its own removal. A corrupt/undecodable blob at `restore()` is cleared (best-effort, itself
  guarded) and degrades to logged-out; startup MUST NOT hard-fail on storage content.
- Non-null writes are dedup-guarded by `AccessCredentials` value equality (identical rewrites are
  skipped); an undecodable existing blob is treated as "different", so the new value overwrites it —
  self-healing, never a throw.
- Schema evolution: `AccessCredentials.fromJson` stays tolerant (missing `scopes` → empty). A breaking
  blob change requires either a lenient decode path or an explicit clear-on-upgrade — never a decode
  crash at restore.

### 10.2 Platform backing

Instantiated in the composition root with explicit Apple keychain accessibility (other platforms on the
strong v10 defaults), behind `lib/settings/data/preferences/secure_preferences_dao.dart`:

| Platform        | Backing                                 | Notes                                                                                                                                                                                                                                                                             |
| --------------- | --------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| iOS / macOS     | Keychain                                | `KeychainAccessibility.first_unlock_this_device` — background writes work after the first unlock; items never restore onto another device                                                                                                                                         |
| Android         | Keystore-backed secure storage          | v10 defaults: AES/GCM + RSA-OAEP-wrapped Keystore keys, `resetOnError` (self-wipes on decrypt failure — F2-aligned)                                                                                                                                                               |
| Windows / Linux | OS credential stores                    |                                                                                                                                                                                                                                                                                   |
| Web             | **localStorage fallback — JS-readable** | XSS is the operative threat; the CSP `<meta>` in `web/index.html` is the primary defense (no `unsafe-inline` scripts; externalized bootstrap). Header-level hardening (HSTS, frame-ancestors, per-deployment `connect-src`) is a CDN concern — `web/README.md` owns the checklist |

Storage options (implemented 2026-07-03 — §16.2): Apple platforms pin
`KeychainAccessibility.first_unlock_this_device`. Android needs no flags on `flutter_secure_storage` v10
— the once-recommended `encryptedSharedPreferences` switch is deprecated and IGNORED there (removed in
v11); the default is already AES/GCM with Keystore-wrapped keys plus `resetOnError`.
**RECOMMENDED residual:** audit OS-backup exclusion for the token entries. Any option migration MUST
preserve F2: previously written entries either stay readable or are cleanly cleared — never wedge
restore (accessibility applies per write; existing entries are re-attributed on the next rotation).

Web architecture note: per draft-ietf-oauth-browser-based-apps the stronger browser patterns are BFF or a
token-mediating backend (tokens never reachable from JS). **DELIBERATE:** this app accepts the
browser-only pattern with CSP because one Flutter codebase serves native + web; revisit only if the web
deployment's threat profile hardens (§16.1 is the first step).

The commented-out per-user key prefix in `SecurePreferencesDao` is kept scaffolding — this is a
single-account app today.

## 11. Session lifecycle

### 11.1 Cold start

`$initializeDependencies` runs `'Restore credentials'` as the LAST init step →
`AuthenticationController.restore()` → repository `restore()`:

1. Read `user_id` (plain prefs) and the `credentials` blob (secure). A corrupt blob triggers F2 recovery
   (§10.1). Either missing → remain unauthenticated (guest); the router's `AuthenticationGuard` sends the
   user to sign-in.
2. **Emit the rehydrated `AuthenticatedUser` IMMEDIATELY** — F6 — before any network. A
   returning user must not flash the sign-in screen for the duration of a refresh round-trip.
3. Then proactive `_doRefresh(force: false)` corrects the state: token fresh → no-op; `expiresSoon` →
   rotate + persist + emit; definitive rejection → `_logOutSession()` (a brief home→sign-in transition —
   rare and accepted); transient failure → keep the rehydrated session (offline-friendly cold start).

### 11.2 Foreground, background, offline

- Resume → fire-and-forget proactive refresh (§7.1) — covers tokens that expired while backgrounded.
- Offline: every refresh failure is transient (§8) → the session survives; features receive ordinary
  network errors; the first request after reconnect heals the session via the proactive (`expiresSoon`)
  or reactive (401) path. No connectivity listener is required by this spec.

### 11.3 Sign-out (user-initiated)

`AuthenticationRepository.signOut()`:

1. `_endSession()` runs SYNCHRONOUSLY, before awaiting the mutex: bump `_sessionEpoch` (A2) and cancel
   `sessionCancelToken` — all in-flight session-bound requests abort; the next `sessionCancelToken` read
   vends a fresh token for the next session.
2. Under the mutex: best-effort server revocation — `_api.signOut(accessToken).ignore()`.
   `ConnectAuthenticationClient.signOut` attaches the token manually and swallows every error.
   **INVARIANT (logout-availability):** client logout MUST NOT block on, or fail because of, the network
   or an expired/rejected token. Local clearing is authoritative; the server call is a courtesy.
3. Emit `unauthenticated`; **await** `setUserId(empty)` + `setCredentials(null)` — a completed logout has
   durably erased credentials (same write-ordering rationale as F1). The clears are best-effort
   (mirrors F2): a storage fault is logged and never fails the logout — nor escapes `_doRefresh` as a
   pseudo-transient error on the definitive-rejection path; a surviving blob rehydrates only until the
   (best-effort revoked) server rejects its refresh.

### 11.4 Failure-driven logout

Chain: middleware `onAuthError()` → `AuthenticationHandler.handleAuthenticationError()` → repository
subscription → `signOut()` → controller `idle(unauthenticated)` → `AuthenticationGuard` redirects to
sign-in and resets its last-navigation memory (no cross-session deep-link leak).

**INVARIANT (A26 — single auth bus):** `AuthenticationHandler` (an eagerly-created broadcast stream with
`distinct()`) is the ONLY logout signal path. Transport code MUST NOT poke the controller, repository, or
router directly. The bus makes logout idempotent, transport-agnostic, and testable.

### 11.5 Teardown and multi-device

`terminate()` (wired to app `detached`): `_endSession()` + cancel subscriptions + close the user stream —
best-effort, source→sink order. State emissions are close-safe: every publish site goes through the
`_emit` helper, which skips the stream add once the controller is closed — an in-flight refresh
completing during teardown cannot throw into its caller. Multi-device management exists at the contract level: `ListSessions`
(POST; carries the refresh token in the body as the session credential), `RevokeSession(device_id)`,
`RevokeOtherSessions` — all exposed by `IAuthenticationApi`; no UI yet (§16.7 covers the MFA UI; a
sessions screen is a product decision, out of scope here).

## 12. Wire contract and server-side expectations

### 12.1 Client-side contract (`api/proto/auth/v1/auth.proto`, service `auth.v1.AuthService`)

- `RefreshTokens(RefreshTokensRequest) → TokenPair`; the request carries **only** `refresh_token`
  (buf.validate `min_len: 1` — which is why an empty persisted RT must be impossible: §6 guards
  issuance, §8 guards rotation). HTTP transcoding: `POST /v1/auth/token/refresh`.
- `TokenPair`: `access_token` (short-lived JWT), `refresh_token` (long-lived opaque), `expires_at`
  (Timestamp). **INVARIANT (A12):** the client IGNORES `expires_at` — expiry is read from the JWT `exp`
  claim, the single source of truth. Two sources of expiry would eventually disagree; the JWT is what the
  resource server actually honors.
- The refresh token is presented ONLY to `RefreshTokens` — and, **DELIBERATE**, to `ListSessions` (POST
  body), where it identifies the current device session. It never rides on data calls: the middlewares
  attach only `authorization: <type> <access-token>`.
- All token-bearing RPCs are POST — tokens never appear in URLs, hence never in access logs or browser
  history.
- Issuance RPCs carry `installation_id` + `ClientInfo` — device-session binding, surfaced in
  `SessionInfo` (`device_id`, `last_seen_at`, `is_current`, …).
- `api/proto/auth/v1/auth.proto` (package `auth.v1`) is the contract, copied verbatim from the
  server (`auth-service-rs`) as the single source of truth and generated into
  `packages/model/auth_model/lib/src/proto/auth/v1/`. The earlier `auth.v2` twin was removed —
  the Connect protocol is versioned from v1.

### 12.2 SERVER-CONTRACT — expectations the client cannot verify

- **Rotation.** The server SHOULD rotate the refresh token on every successful refresh. RFC 9700 §4.14 /
  OAuth 2.1: refresh tokens for public clients MUST be sender-constrained or one-time use — this client
  is a public client, rotation is the chosen arm. The client tolerates both rotated and omitted RTs (§8).
- **Reuse detection.** Presenting an already-rotated (or revoked) refresh token MUST revoke the entire
  token family and answer with a definitive code (`UNAUTHENTICATED`). The client responds with a clean
  logout — that is the designed containment behavior, not an error to retry.
- **Rotation grace period.** The server SHOULD accept the immediately-previous refresh token for a short
  overlap window (~30–60 s; industry practice: Okta 30 s default and 0–60 s configurable, Auth0
  "Rotation Overlap Period", AWS Cognito up to 60 s). This absorbs the races the client cannot serialize:
  web multi-tab (§9), process death between rotation and persist, transport-level retries. Only the
  previous generation — replaying older tokens MUST trip reuse detection.
- **TTLs.** Access token short-lived (the client imposes nothing beyond reading `exp`; 5–15 minutes is a
  typical profile here). Refresh token bounded by BOTH an inactivity (idle) timeout and an absolute
  lifetime. Emerging signaling — draft-ietf-oauth-refresh-token-expiration (`refresh_token_timeout`,
  `authorization_expires_in`): **RECOMMENDED** to adopt in the contract when the server implements it
  (§16.5).
- **Revocation.** `SignOut` MUST revoke the presented session server-side (RFC 7009 analog);
  `RevokeSession` / `RevokeOtherSessions` likewise for targeted/mass revocation.
- **Definitive codes are sacred.** The refresh endpoint MUST answer `UNAUTHENTICATED` /
  `INVALID_ARGUMENT` / `PERMISSION_DENIED` ONLY for genuinely unrecoverable token states. The client logs
  out immediately and durably on them; using these codes for transient conditions causes spurious
  logouts. Transient server trouble MUST use transient codes (`UNAVAILABLE`, `DEADLINE_EXCEEDED`, …).
- **Clock leeway.** The server SHOULD tolerate small client clock skew at the resource side and MUST
  treat the JWT `exp` as authoritative over any duplicated expiry metadata.

## 13. Telemetry, logging, redaction

History — why these rules exist: raw tokens once reached Sentry and the release console. The controller
state observer serializes state via `toString`, and the chain `AuthenticationState → AuthenticatedUser →
AccessCredentials → AccessToken` printed live token material into span data. The fix (2026-07-02) was
redaction at the SOURCE types, and it is load-bearing:

- **INVARIANT (redact-at-source):** every type that holds token/secret/PII material MUST redact it in
  its `toString` (`AccessToken` → `data=***`; `AccessCredentials` → `refreshToken=***`; `User` /
  `UserInfo` → `name/email/phone: ***`). Header/query scrubbing does NOT cover object serialization —
  state observers, error messages, and span attributes all stringify objects. Remember the
  extension-type caveat (§4.2).
- Sentry middlewares scrub `kRedactedHeaders` (authorization, cookie, set-cookie, x-csrf-token,
  proxy-authorization) and `kRedactedQueryParams` (token, access_token, refresh_token, id_token, code,
  api_key, secret, password, signature, the AWS SigV4 presigned-URL material `x-amz-signature` /
  `x-amz-credential` / `x-amz-security-token`, …) — `lib/_core/api/_core/sentry_redaction.dart`. Extend
  those sets when introducing new sensitive parameters.
- The raw request URL captured by HTTP telemetry (span-data `url`, exception hints) goes through
  `redactSensitiveUrl` — a presigned URL is a live bearer capability and MUST NOT reach Sentry intact;
  query values are redacted by the same set. The Connect middleware records the path only.
- Transport logs (`ConnectLoggerMiddleware` / `HttpLoggerMiddleware`, `lib/_core/api/`) record path +
  outcome + duration ONLY — never metadata, headers, or bodies.
- Trace propagation (`sentry-trace` / `baggage`) is disabled toward third parties
  (`HttpSentryMiddleware(propagateTrace: false)` on the S3 client) so correlation headers don't leak
  off-domain.
- The composition-root logging around `onAuthError` / `getToken` mentions the event, never the token.
- Expected teardown exceptions — RPC `canceled` and `RequestSessionEndedException` (A27) — are not
  captured as Sentry issues; their spans finish with a `cancelled` status (`ConnectSentryMiddleware`).
- **RECOMMENDED (§16.8):** structured counters for refresh attempts and outcomes (success / definitive /
  transient) and forced-logout reasons — zero token material — so server-side reuse-detection incidents
  are diagnosable from client telemetry.

## 14. Standards conformance map

| Standard                                  | Relevant requirement                                                                                 | Status in this solution                                                                                                                                  |
| ----------------------------------------- | ---------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RFC 6749 §6                               | refresh grant; a new refresh token MAY be omitted from the response                                  | Honored: `mapRefreshResponse` keeps the previous RT on omission                                                                                          |
| RFC 6750                                  | Bearer token usage; keep tokens out of URIs                                                          | Honored: `authorizationHeaderValue`; POST-only token RPCs                                                                                                |
| RFC 9700 (BCP 240) §2.2.2, §4.14          | public clients: RT rotation or sender-constraining; reuse → revoke family; short-lived access tokens | Client is rotation-tolerant and treats rejection as definitive; rotation/reuse detection/grace are SERVER-CONTRACT (§12.2); sender-constraining deferred |
| OAuth 2.1 (draft)                         | consolidates the above: public-client RTs sender-constrained or one-time use                         | Same posture                                                                                                                                             |
| RFC 8252                                  | native apps: external user-agent for OAuth, secure token storage                                     | Secure storage honored (§10.2); OAuth via `GetOAuthUrl` / `ExchangeOAuthCode` (server-orchestrated)                                                      |
| draft-ietf-oauth-browser-based-apps       | BFF > token-mediating backend > browser-only client                                                  | Browser-only knowingly accepted with CSP (DELIBERATE, §10.2)                                                                                             |
| RFC 9449 (DPoP)                           | sender-constrained tokens                                                                            | DEFERRED (§16.6)                                                                                                                                         |
| RFC 7009                                  | token revocation                                                                                     | Analog honored: best-effort `SignOut` + Sessions API                                                                                                     |
| draft-ietf-oauth-refresh-token-expiration | RT lifetime signaling (`refresh_token_timeout`)                                                      | Not in the contract yet; RECOMMENDED on server support (§16.5)                                                                                           |
| RFC 8725 (JWT BCP)                        | JWT validation hygiene                                                                               | Applied in decode-only form: typed parse errors, `exp`-only trust, no client-side signature trust (§4.1)                                                 |

## 15. Deliberate decisions that look wrong — do not "fix" silently

Each item is intentional. Changing any of them requires owner sign-off and an update to this document:

- **`HttpAuthenticationMiddleware` is implemented, fully tested, and wired nowhere.** Standby for the
  first authenticated REST API — the app's current HTTP client only performs presigned S3 uploads, which
  must stay unauthenticated. Do NOT delete; do NOT wire without a real consumer.
- **`jwt_token.dart` (`JwtValidator`) is fully commented out** (and `crypto` is commented out in
  `packages/model/auth_model/pubspec.yaml`). Scaffolding for a hypothetical client-side verification
  story. Keep as-is.
- **`TokenPair.expires_at` is ignored** — JWT `exp` is the single source of truth (A12, §12.1).
- **JWT handling is decode-only** — no signature/`nbf`/`aud` validation on a public client (§4.1).
- **`expiresSoon` is a fixed 30 s window** — no config surface until a real deployment needs one.
- **Every request passes through the refresh mutex even when the token is fresh** — micro-serialization
  accepted for the simplicity of "one lock owns all session state" (§7.1).
- **Both tokens are persisted**, not access-in-memory-only (§4.4).
- **Scopes are dropped on rotation** (§8).
- **Logout over-signalling on a rejected refresh** — up to three idempotent signals converge (§7.6).
- **The `getToken` wiring wrapper rethrows transient errors instead of returning `null`** (A3, §3.3) —
  collapsing to `null` would convert storage hiccups into logouts.
- **`refreshTokens(accessToken, …)` ignores its access-token argument at the RPC layer** (§8).
- **`BearerAuthenticationMiddleware` logs out on ANY 401/403 and never refreshes** — it is a deliberately
  dumb tool for token-only backends without rotation, not a bug in the smart flow. Pick one middleware or
  the other; never stack them.
- **`recoveryStart` swallows errors and returns `true`** — OWASP account-enumeration defense (§6).

## 16. Gaps and hardening roadmap (RECOMMENDED, prioritized)

These gaps are known and DEFERRED by owner choice — do not re-report them as findings. Implement only as
explicitly scoped tasks, preserving the named invariants.

1. **Web multi-tab refresh coordination.** Trigger: real multi-tab web usage, or observed
   reuse-detection logouts on web. Sketch: on web, wrap `_doRefresh` in a cross-tab mutual exclusion
   (Web Locks API; storage-event fallback) and re-read/adopt credentials rotated by another tab before
   refreshing. Preserve: single-flight semantics, A2 epoch authority in-process, F2 self-healing.
2. **Secure-storage options hardening — DONE 2026-07-03.** Apple `first_unlock_this_device` set in the
   composition root; Android v10 defaults already strong (the old `encryptedSharedPreferences` advice
   was stale — deprecated/ignored in v10, removed in v11). Residual: OS-backup exclusion audit (§10.2).
3. **PII redaction in `UserInfo` / `User.toString` — DONE 2026-07-03.** Redact-at-source custom
   `toString` (freezed generation skipped); pinned by
   `packages/model/auth_model/test/user_models_test.dart`.
4. **Timer-driven proactive refresh.** Trigger: long-idle-then-instant-action UX or streaming-heavy
   sessions where the first call after idle pays a 401 round-trip. Sketch: while authenticated, schedule
   `getAccessCredentials().ignore()` at `expiry − window − jitter`; cancel on logout (epoch-aware).
   Preserve: single-flight; transient-never-logs-out; no timer survives `_endSession()`.
5. **Adopt refresh-token lifetime signaling** (draft-ietf-oauth-refresh-token-expiration:
   `refresh_token_timeout`, `authorization_expires_in`) when the server implements it: surface
   "session about to end" UX; optionally pre-empt idle expiry with a refresh. Preserve: A12 — JWT `exp`
   stays authoritative for the ACCESS token.
6. **DPoP / sender-constraining readiness (RFC 9449).** Server-led. The client is already shaped for it:
   scheme + token flow through `AccessToken.type` / `authorizationHeaderValue`; a DPoP proof would be a
   second header attached at the same two middleware points. Do not build speculatively.
7. **MFA challenge UI wiring.** `verifyMfa` (repository + API) and the controller's `onMfaRequired` hook
   exist; the challenge screen does not — MFA_REQUIRED currently surfaces a truthful error message.
8. **Refresh observability counters** (§13) — attempts, outcomes, forced-logout reasons; no token
   material.
9. **Per-deployment CSP `connect-src` pinning** at the CDN/header level — `web/README.md` owns the
   checklist.

## 17. Change guardrails and test matrix

Before touching ANY auth/token code, know which tests pin which behavior — and keep them green:

| Invariant / behavior                                                                                                                                                                                                                                                                                          | Pinned by                                                                 |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| Single-flight; 401-wave dedup; definitive vs transient policy; A2 epoch (no resurrection); A27 session-provenance guard (cross-session stale requests fail); F1 write ordering; F2 corrupt-blob recovery; F6 restore-emits-first; close-safe emits; best-effort logout clears; session cancel-token lifecycle | `test/authentication/authentication_repository_test.dart`                 |
| Unary 401→refresh→retry-once; streaming repair-without-replay; public vs session-ending paths; transient getToken/refresh → no logout; 403 → no logout; exact `usedAccessToken` forwarding                                                                                                                    | `packages/model/auth_model/test/connect_auth_refresh_test.dart`              |
| HTTP mirror of the above + `kNoRetryContextKey` (repair, no body resend) + multipart no-replay + second-401 logout                                                                                                                                                                                            | `packages/model/auth_model/test/http_authentication_middleware_test.dart` |
| `exp` parsing + typed malformed-JWT errors; the 30 s `expiresSoon` window; redacting `toString`; value equality                                                                                                                                                                                               | `packages/model/auth_model/test/access_token_test.dart`                   |
| Credentials blob round-trip; tolerant decode; both secrets masked in `toString`                                                                                                                                                                                                                               | `packages/model/auth_model/test/access_credentials_test.dart`             |
| RFC 6749 §6 rotation mapping (`mapRefreshResponse`)                                                                                                                                                                                                                                                           | `packages/model/auth_model/test/connect_authentication_client_test.dart`     |
| Issuance mapping: SUCCESS without a refresh token → failed result; role mapping (A11)                                                                                                                                                                                                                         | `packages/model/auth_model/test/authentication_converter_test.dart`  |
| Auth-bus semantics (eager controller, `distinct()`, safe post-close no-op)                                                                                                                                                                                                                                    | `packages/model/auth_model/test/authentication_handler_test.dart`         |
| Public-path constants match the generated stubs (review-ID A19)                                                                                                                                                                                                                                               | `packages/model/auth_model/test/auth_public_paths_test.dart`              |
| Transport-error classification (`RpcException.from`)                                                                                                                                                                                                                                                         | `packages/model/auth_model/test/rpc_exceptions_test.dart`                |
| Storage semantics (unconditional null-clear, dedup write)                                                                                                                                                                                                                                                     | `test/settings/settings_repository_test.dart`                             |
| Telemetry redaction: headers, query (incl. SigV4 presigned material), raw-URL rendering                                                                                                                                                                                                                       | `test/_core/api/http/sentry_redaction_test.dart`                          |
| PII redaction in user-profile `toString`                                                                                                                                                                                                                                                                      | `packages/model/auth_model/test/user_models_test.dart`                    |
| HTTP pipeline ground rules (retry never touches 401; cancellation; replayability; timeouts)                                                                                                                                                                                                                   | `packages/model/http_client/test/http_pipeline_test.dart`                 |

Rules:

1. Never weaken, skip, or delete a test that carries an invariant ID in its name or comments.
2. The five prohibitions:
   - never log or stringify token material — redact at the source type (§13);
   - never collapse a transient credential error into `null` or a logout (A3);
   - never move session persistence outside `_refreshingMutex`, and never fire-and-forget it (F1);
   - never remove either `_sessionEpoch` check around the awaits in `_doRefresh` (A2);
   - never signal logout except through `AuthenticationHandler` (A26).
3. Gate: `flutter analyze` clean and `flutter test` green in the app root, `packages/model/auth_model`,
   and `packages/model/http_client`.
4. Update this document in the same PR that changes described behavior; refresh the
   "Last verified against" line.
