# Build time environment could be overridden by runtime variable
ARG APP_ENVIRONMENT="staging"


FROM dart:stable AS build_dart
WORKDIR /app
COPY ./tool/web_env.dart ./tool/

RUN dart compile exe tool/web_env.dart -o tool/web-env


FROM plugfox/flutter:3.47.2-web AS build_web
WORKDIR /home
COPY --chown=101:101 . .

ARG APP_ENVIRONMENT
ENV APP_ENVIRONMENT=$APP_ENVIRONMENT
# Git-traceable SW cache version; pass from CI: --build-arg GIT_SHA=$GITHUB_SHA
# (without it the script falls back to git metadata, then a timestamp).
ARG GIT_SHA=""
ENV GIT_SHA=$GIT_SHA
ENV CI=true

# ONE build implementation per artifact (C4): the exact script CI uses. It runs pub get, the
# codegen (packages first, then the app), pubspec_generator, `flutter build web` with
# --dart-define-from-file=config/$APP_ENVIRONMENT.env, the prod-index swap, template stripping
# and sw:generate. The inline build this replaces had drifted: no pubspec_generator (failed a
# clean checkout), no dart-define-from-file, template snapshots shipped.
RUN bash deploy/build_flutter_web.sh


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