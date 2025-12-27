# Build time environment could be overridden by runtime variable
ARG APP_ENVIRONMENT="staging"


FROM dart:stable AS build_dart
WORKDIR /app
COPY ./tool/web_env.dart ./tool/

RUN dart compile exe tool/web_env.dart -o tool/web-env


FROM plugfox/flutter:3.38.5-web AS build_web
WORKDIR /home
COPY --chown=101:101 . .

ARG APP_ENVIRONMENT
ENV APP_ENVIRONMENT=$APP_ENVIRONMENT

RUN (cd packages/model/auth_model && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs --release)
RUN flutter pub get
RUN dart run intl_utils:generate
RUN flutter pub run build_runner build --delete-conflicting-outputs --release
RUN flutter build web --release --no-source-maps \
    --dart-define=APP_ENVIRONMENT=$APP_ENVIRONMENT \
    --pwa-strategy offline-first \
    --web-renderer canvaskit \
    --base-href /


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