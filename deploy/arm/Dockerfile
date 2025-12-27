# docker buildx build --platform linux/arm64 -t zsdima/auth-app:stable -f ./deploy/arm/Dockerfile . --push
# docker run --pull=always -it zsdima/auth-app:stable /bin/bash
# docker rm $(docker stop $(docker ps -a -q --filter ancestor=zsdima/auth-app:stable --format="{{.ID}}"))

# Build time environment could be overridden by runtime variable
ARG APP_ENVIRONMENT="staging"


FROM dart:stable AS build_dart
WORKDIR /app
COPY ./tool/web_env.dart ./tool/

RUN dart compile exe tool/web_env.dart -o tool/web-env


FROM fischerscode/flutter-sudo:stable AS build_web
WORKDIR /home
COPY --chown=101:101 . .

ARG APP_ENVIRONMENT
ENV APP_ENVIRONMENT=$APP_ENVIRONMENT

USER root:root
RUN git config --global --add safe.directory /home/flutter/flutter-sdk
RUN flutter channel stable
RUN flutter upgrade --force
RUN flutter doctor -v

RUN (cd packages/model/auth_model && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs --release)
RUN flutter pub get
RUN dart run intl_utils:generate
RUN flutter pub run build_runner build --delete-conflicting-outputs --release
RUN flutter build web --release --no-source-maps \
    --dart-define=APP_ENVIRONMENT=$APP_ENVIRONMENT \
    --pwa-strategy offline-first \
    --web-renderer canvaskit \
    --base-href /


FROM arm64v8/nginx:latest as production

COPY --from=build_dart /runtime/ /runtime/
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