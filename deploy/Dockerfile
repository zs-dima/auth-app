# Build time environment could be overridden by runtime variable
ARG APP_ENVIRONMENT="staging"


FROM dart:stable AS build_dart
WORKDIR /app
COPY ./tool/web_env.dart ./tool/

RUN dart compile exe tool/web_env.dart -o tool/web-env


FROM plugfox/flutter:3.41.7-web AS build_web
WORKDIR /home
COPY --chown=101:101 . .

ARG APP_ENVIRONMENT
ENV APP_ENVIRONMENT=$APP_ENVIRONMENT

RUN (cd packages/model/auth_model && flutter pub get && dart run build_runner build --delete-conflicting-outputs --release)
RUN flutter pub get
RUN dart run intl_utils:generate
RUN dart run build_runner build --delete-conflicting-outputs --release
RUN flutter build web --release --no-source-maps \
    --dart-define=APP_ENVIRONMENT=$APP_ENVIRONMENT \
    --wasm --no-web-resources-cdn --tree-shake-icons \
    --base-href /

# Swap dev index.html for the prod template before sw:generate.
# (dev uses flutter_bootstrap.js, prod uses the sw bootstrap.js tag).
RUN rm -f build/web/index.html && mv build/web/index.prod.html build/web/index.html

# Generate service worker with the sw CLI (pinned in pubspec.yaml).
# Config is loaded from sw.yaml at the repo root; only --version varies per build.
# sw 0.1.2 inlines flutter.js into bootstrap.js and auto-deletes flutter.js,
# flutter_bootstrap.js, flutter_service_worker.js, .last_build_id, and any
# *.js.map / *.js.symbols / *.wasm.map files.
RUN dart run sw:generate --version="${GIT_SHA}"


FROM nginx:alpine as production

COPY --from=build_dart /runtime/ /
COPY --from=build_dart /app/tool/web-env /app/bin/web-env
COPY --from=build_web --chown=101:101 /home/build/web /usr/share/nginx/html
COPY ./deploy/entrypoint.sh /app/bin/entrypoint.sh
COPY ./deploy/nginx/mime.types /etc/nginx/mime.types
COPY ./deploy/nginx/nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /app/bin/entrypoint.sh

# Add lables
LABEL name="Auth client app" \
    vcs-url="https://github.com/zs-dima/auth-app" \
    github="https://github.com/zs-dima/auth-app" \
    maintainer="Dmitrii Zusmanovich" \
    authors="Dmitrii Zusmanovich" \
    family=""

# Start server
EXPOSE 80/tcp

ENTRYPOINT ["/app/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]