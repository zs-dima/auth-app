# `lib/_core/api` — boundary between app observability and transport packages

This folder holds the **app-layer** API middleware. The split between what lives here and what lives
in `packages/model/*` is **deliberate**, not an unfinished migration:

- **Transport-generic middleware lives in packages** — it has no app dependencies and is reusable:
  - `rest_client` → `AuthenticationBasicMiddleware`, `RetryMiddleware`, `TimeoutMiddleware`,
    `MetadataMiddleware` (takes a plain `Map<String, String>`).
  - `grpc_model` → `GrpcMetadataMiddleware`, `GrpcRetryMiddleware`, `GrpcCompressionMiddleware`.
  - `auth_model` → `GrpcAuthenticationMiddleware` and `RestAuthenticationMiddleware` (token attach +
    single-flight refresh). The REST auth middleware is a tested mirror of the gRPC one but is **not
    yet wired** into any client — today the only `ApiClient` is the external S3 client, which is
    deliberately unauthenticated. It is kept ready for when a first-party authenticated REST
    transport is added.

- **Observability middleware lives here, in `lib`** — it depends on app-only concerns and would force
  the packages to take on those dependencies if moved:
  - `grpc/` + `http/` logger middleware → depend on the app logger (`lib/_core/log/logger.dart`).
  - `grpc/` + `http/` sentry middleware → depend on `sentry_flutter` and the app's Sentry config (DSN,
    environment). Keeping them here means `rest_client`/`grpc_model` stay free of `sentry_flutter` and
    remain reusable by apps that use a different (or no) telemetry stack.
  - `_core/` shared utilities (`sentry_redaction`, `sentry_tracing`, `transport_log`) are consumed
    **only** by the observability middleware above, so they correctly live here too.

**Rule of thumb:** if a middleware needs the app logger or Sentry, it belongs in `lib/_core/api`. If it
only manipulates the request/response (headers, retries, timeouts, auth tokens), it belongs in a package.

The middleware pipelines are assembled at wiring time in
`lib/initialization/initialize_dependencies.dart`, which composes package middleware and the app
observability middleware into a single ordered stack per transport.
