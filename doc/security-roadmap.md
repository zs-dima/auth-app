# Security roadmap — closing the gaps to 2026 best practices

Status: proposed (2026-08-13, from the full-project audit + best-practices research).
Scope note: every workstream below **requires auth-service-rs changes** and is therefore out of
bounds for client-only work; this document is the hand-off. Client-side counterparts are listed per
item. The client-side gaps found by the same research (streaming back-pressure, MFA challenge UI)
are already implemented in auth-app and are NOT listed here.

References: [RFC 9700 (OAuth 2.0 Security BCP)](https://www.rfc-editor.org/rfc/rfc9700),
[OAuth 2.0 for Browser-Based Apps (IETF draft)](https://datatracker.ietf.org/doc/draft-ietf-oauth-browser-based-apps/),
[OAuth 2.0 for First-Party Applications (IETF draft)](https://datatracker.ietf.org/doc/draft-ietf-oauth-first-party-apps/),
[RFC 9449 (DPoP)](https://www.rfc-editor.org/rfc/rfc9449.html),
[gRFC A6 (client retries)](https://github.com/grpc/proposal/blob/master/A6-client-retries.md),
[AIP-194](https://google.aip.dev/194).

## 1. Refresh-token rotation grace window (SERVER — highest priority)

**Problem.** refresh_token.md §12.2 makes rotation + reuse detection the server contract; the
grace window is only a SHOULD. Without it, a refresh whose *response is lost* leaves the client
holding a consumed token; its next legitimate refresh trips reuse detection and revokes the whole
token family (logout on all devices). Client-side mitigation is already maximal: the retry
middleware never replays `RefreshTokens` — but the *next natural* refresh still presents the
consumed token. Only the server can distinguish "same device finishing an interrupted rotation"
from "attacker replaying a stolen token".

**Industry practice.** Okta: 30 s grace period; Supabase: 10 s reuse interval; RFC 9700 §4.14.2
explicitly permits a brief overlap for network-failure tolerance.

**Task.** In auth-service-rs `RefreshTokens`: accept the *previous* token of a family for a short
window (10–30 s) after rotation, returning the SAME successor pair (idempotent replay), and only
treat reuse outside the window (or of older generations) as an attack. Emit a metric for
within-window replays (they indicate network quality, and a spike may indicate an attack probe).

**Acceptance.** Integration test: rotate → replay old token within window → same new pair, family
alive; replay after window → family revoked.

## 2. Backend-for-Frontend for web (SERVER + deploy)

**Problem.** On web the refresh token lives in `localStorage` (flutter_secure_storage has no real
web security boundary) — `web/README.md` documents the XSS exposure. The Browser-Based Apps BCP's
strongest pattern is **BFF**: tokens never reach the browser; the SPA holds only an HttpOnly,
Secure, SameSite session cookie; the BFF keeps the OAuth/token session server-side and proxies
API calls.

**Task sketch.**
- A thin BFF service (or an auth-service-rs endpoint group) terminating the web session:
  cookie ↔ token-family mapping, refresh handled server-side, CSRF protection (double-submit or
  `SameSite=Strict` + custom header), logout = cookie + family revocation.
- gRPC-Web/Connect calls from the browser go through the BFF, which injects the access token.
- Client counterpart (auth-app web build): storage backend switches to "cookie session" mode —
  `AuthenticationRepository` needs no token persistence on web at all; `restore()` degrades to a
  "who am I" call. Feature-flag by platform.

**Interim hardening** (if BFF is deferred): keep the refresh token out of `localStorage` by holding
it in memory only on web (cost: session does not survive a tab reload — product decision), or bind
it to a Service-Worker-held store. Both are strictly weaker than BFF.

## 3. DPoP — sender-constrained tokens (SERVER + client)

**Problem/benefit.** RFC 9700 §2.2.2 requires public clients to use rotation **or**
sender-constraining. Rotation is in place; DPoP (RFC 9449) is the stronger branch: a stolen
refresh/access token is useless without the device-held private key.

**Task sketch.** Server: accept `DPoP` proof JWTs on the token endpoints (nonce challenge,
`jkt` binding in issued tokens). Client: generate a per-install P-256 keypair (secure enclave
where available), sign per-request proofs in the auth middlewares
(`connect_authentication_middleware` attach path), rotate nonce on `use_dpop_nonce` errors.
Sequencing: after item 1 (grace window), since DPoP replaces the *theft* mitigation, not the
*lost-response* mitigation.

## 4. Passkeys / WebAuthn (SERVER + product)

**Problem/benefit.** Password + MFA is yesterday's baseline; passkeys are the 2026 consumer
frontier (phishing-resistant, no shared secret server-side). The current native
credential-collection flow structurally matches the active IETF first-party-apps draft (challenge
endpoint ↔ our `Authenticate → MfaChallenge → VerifyMfa`), so passkeys slot in as an additional
challenge/method rather than a redesign.

**Task sketch.** Server: WebAuthn registration + assertion ceremonies (`webauthn-rs`), credential
storage per user, `Authenticate` gains a passkey branch (or a dedicated RPC pair
`StartPasskeyAuth`/`FinishPasskeyAuth`). Client: `passkeys`/platform authenticator plugin,
"Sign in with a passkey" entry on the sign-in screen, registration UX under account settings.
Note: API surface changes → proto evolution required (explicitly out of client-only scope).

## Priority order

1 (grace window — removes the last real all-device-logout scenario, small server diff) →
2 (BFF — biggest security uplift for web) → 4 (passkeys — product-visible) → 3 (DPoP — deepest
defense, needs 1 first).
