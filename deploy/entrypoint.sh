#!/bin/sh
# POSIX on purpose: the runtime image is nginx:alpine, which has no bash — the
# previous #!/bin/bash + `compgen -e` version could never start there.
#
# ALLOWLIST on purpose: the container's environment can hold injected secrets,
# and web-env's output is a PUBLICLY SERVED file. Only the variables the app
# reads are passed; web-env applies the same allowlist again as defense in
# depth. Keep this list in sync with tool/web_env.dart `kAllowedKeys`.
set -eu

write_env() {
  set --
  for var in APP_VERSION APP_ENVIRONMENT SENTRY_DSN DB_DROP DB_NAME DB_IN_MEMORY \
             APP_AUTH_ADDRESS APP_API_ADDRESS S3_URL; do
    val=$(eval "printf '%s' \"\${$var:-}\"")
    # APP_VERSION passes through even when empty: web-env then derives it from
    # version.json. Everything else empty is skipped (cannot override a define).
    if [ -n "$val" ] || [ "$var" = "APP_VERSION" ]; then
      set -- "$@" "$var=$val"
    fi
  done
  # Arguments are individually quoted — values with spaces or '=' survive
  # (the old unquoted $env_string word-split them).
  /app/bin/web-env "$@"
}

write_env

# Exec the image CMD (nginx).
exec "$@"
