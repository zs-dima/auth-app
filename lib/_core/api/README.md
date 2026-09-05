# `lib/_core/api` — boundary between app observability and transport packages

This folder holds the **app-layer** API middleware. The split between what lives here and what lives
in the transport packages is **deliberate**, not an unfinished migration. Those packages are git
dependencies since 2026-09-04 (`http_client` → `http_kit`, `connect_model` → `connect_kit`; sources
under `A:/source/_lib/flutter`), which makes the boundary a release boundary too:

- **Transport-generic middleware lives in packages** — it has no app dependencies and is reusable:
  - `http_kit` → `BearerAuthenticationMiddleware`, `RetryMiddleware`, `TimeoutMiddleware`,
    `MetadataMiddleware` (takes a plain `Map<String, String>`).
  - `connect_kit` → `ConnectMetadataMiddleware`, `ConnectRetryMiddleware` (compression moved to a
    Transport-level option — see the standby note in `compression_middleware.dart`).
  - `auth_model` → `ConnectAuthenticationMiddleware` and `HttpAuthenticationMiddleware` (token attach +
    single-flight refresh). The HTTP auth middleware is a tested mirror of the Connect one but is **not
    yet wired** into any client — today the only `ApiClient` is the external S3 client, which is
    deliberately unauthenticated. It is kept ready for when a first-party authenticated HTTP
    transport is added.

- **Observability middleware lives here, in `lib`** — it depends on app-only concerns and would force
  the packages to take on those dependencies if moved:
  - `connect/` + `http/` logger middleware → depend on the app telemetry facade
    (`lib/_core/log/telemetry.dart`) and on the canonical transport lines in
    `_core/transport_log.dart`.
  - `connect/` + `http/` sentry middleware → depend on `sentry_flutter` and the app's Sentry config (DSN,
    environment). Keeping them here means `http_kit`/`connect_kit` stay free of `sentry_flutter` and
    remain reusable by apps that use a different (or no) telemetry stack.
  - `_core/` shared utilities (`sentry_redaction`, `sentry_tracing`, `transport_log`) are consumed
    **only** by the observability middleware above, so they correctly live here too.

**Rule of thumb:** if a middleware needs the app logger or Sentry, it belongs in `lib/_core/api`. If it
only manipulates the request/response (headers, retries, timeouts, auth tokens), it belongs in a package.

The middleware pipelines are assembled at wiring time in
`lib/initialization/initialize_dependencies.dart`, which composes package middleware and the app
observability middleware into a single ordered stack per transport.
