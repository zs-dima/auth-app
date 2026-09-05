# Web build — security notes

The web target has security constraints the native targets do not. They are **inherent to the
browser platform**, not bugs — this file records them and the hardening that is (and isn't) in place.

## Token storage on web is not a real secret store

Credentials (access **and** refresh token) are persisted via `FlutterSecureStorage` under the
`credentials` key (`lib/settings/data/...`). On mobile/desktop this maps to the OS keychain. **On web
there is no OS keychain**: the backend stores the value in IndexedDB/localStorage, and its key
material lives in the DOM. Any script running on the origin can read it.

Consequences:

- A **long-lived refresh token in browser storage cannot be protected from same-origin script.** An
  XSS on this origin can exfiltrate it. The CSP below is the primary mitigation; keep it strict.
- Prefer short refresh-token lifetimes / rotation server-side (the client already handles rotation and
  RFC 6749 §6 refresh-token omission — see `ConnectAuthenticationClient.mapRefreshResponse`).
- A more robust design (future work, not implemented) keeps the refresh token in an `HttpOnly`,
  `Secure`, `SameSite` cookie the JS never sees, with the server refreshing on a cookie-authenticated
  endpoint. That requires backend support and is out of scope here.

## Multi-tab refresh-token rotation is not coordinated

Each browser tab constructs its own `AuthenticationRepository` (its own in-memory session, mutex, and
`_sessionEpoch`) while sharing one per-origin `credentials` blob. If the server rotates refresh tokens
(one-time use), two tabs refreshing concurrently can make the loser's next refresh fail → a surprise
logout in that tab. There is **no** cross-tab guard (BroadcastChannel / Web Locks / storage events).
Acceptable for now; revisit if multi-tab usage becomes common.

## Content-Security-Policy (in `index.html` / `index.prod.html`)

A CSP `<meta>` is set, but **dev and prod policies deliberately differ**:

- **`index.prod.html` (strict).** The only page script is **external** (the SW bootstrap;
  `launch_params.js` was DELETED 2026-09-02 — it had no Dart reader and harvested every query
  parameter, reset/verification tokens included, into a JS global), so `script-src` needs no
  `'unsafe-inline'`. `https://www.gstatic.com` stays in `script-src` because of the SW bootstrap,
  not Flutter: the release build already self-hosts CanvasKit (`--no-web-resources-cdn` in
  `deploy/build_flutter_web.sh` ships `build/web/canvaskit/`), but `sw` 0.1.5's `bootstrap.js`
  loads CanvasKit **CDN-first with no opt-out** — it fetch-probes gstatic (which passes: the probe
  goes through `connect-src`, and `https:` is deliberately broad there) and then script-loads from
  the CDN base it probed. Removing gstatic from `script-src` would therefore pass the probe and
  block the script — a broken app, not a fallback (the local-`canvaskit/` fallback only triggers
  when the PROBE fails). Drop gstatic the day `sw` grows a no-CDN toggle — tracked in
  `docs/decisions.md` (2026-09-02).
- **`index.html` (dev-relaxed).** `flutter run` cannot work under the strict policy: DWDS injects
  **inline** scripts (→ `'unsafe-inline'`), CanvasKit comes from gstatic, and the debug service uses
  plain `ws://127.0.0.1:<port>` (→ `ws:` in `connect-src`). Structural directives (`object-src
  'none'`, `base-uri`, `form-action`) are kept.

`style-src 'unsafe-inline'` is unavoidable — Flutter web injects inline styles.
`script-src 'wasm-unsafe-eval'` is required by CanvasKit.

`connect-src` is deliberately permissive (`'self' https: wss:` in prod) because the Connect RPC /
app-service / S3 origins come from **runtime environment config** and cannot be enumerated in a
static template.

### Inline vs external page scripts

- **Dev (`index.html`)**: the loading-progress stubs (`window.updateLoadingProgress` /
  `removeLoadingIndicator`, called unguarded by the Dart JS interop) are **inline** — the dev CSP
  already carries `'unsafe-inline'` for debug tooling, so there is nothing to gain from an extra file.
- **Prod (`index.prod.html`)**: the SW bootstrap stays **external** — the strict CSP has no
  `'unsafe-inline'`, and re-inlining would require either `'unsafe-inline'` (undoes the hardening)
  or a sha256 hash that changes with every `sw` release. (`launch_params.js`, the other external
  script this section used to defend, was deleted — see above.)

### Production hardening checklist (do at the CDN / server, not in `<meta>`)

- **Pin `connect-src`** to the exact Connect RPC / app / S3 origins for the environment (via an HTTP
  `Content-Security-Policy` response header, which overrides/augments the meta).
- Set **`frame-ancestors 'none'`** (and `X-Frame-Options: DENY`) — clickjacking protection; these are
  **ignored** in a `<meta>` CSP and must be HTTP headers.
- Set **HSTS** (`Strict-Transport-Security`) and `Referrer-Policy: no-referrer`.
- If PostHog (commented out in `index.prod.html`) is enabled, add its host to `script-src`/`connect-src`.

> Verify any CSP change on a real web build (`flutter build web` + serve, or `flutter run -d chrome`).
> A too-strict CSP white-screens Flutter with a console error — it will not surface in `flutter analyze`.

## Pointing a web build at another backend (non-production only)

A `flutter build web` bakes the service addresses in at compile time, so testing a deployed
front-end against a different API used to mean a rebuild. Outside production the app reads two
`localStorage` keys instead (`lib/_core/environment/platform/service_override_js.dart`):

```js
localStorage.setItem('auth_app.api_base_url', 'http://localhost:8080');
localStorage.setItem('auth_app.auth_base_url', 'http://localhost:8080'); // optional; defaults to the api
location.reload();
// and to go back:
localStorage.removeItem('auth_app.api_base_url');
localStorage.removeItem('auth_app.auth_base_url');
```

An override logs a warning on startup, so a session that behaves oddly shows why in the journal.

**A production build ignores both keys.** That is the whole security argument: the app sends
credentials to these addresses, so a value planted by an XSS (see the token-storage section above)
must not be able to redirect a real user's sign-in to a server of someone else's choosing. The
check is on `EnvironmentFlavor.isProduction` in `environment_loader.dart` — do not relax it.
