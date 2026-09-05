.PHONY: build-web deploy-web build-web-p deploy-web-p serve-web build-android build-windows

# ONE build implementation per artifact (C4): every web build goes through
# deploy/build_flutter_web.sh — the same script CI and the Dockerfile use. The inline
# `flutter build web` recipes this file used to carry were a third, drifting copy.
#
# The template's changes-*/release-* targets called tool/changes.dart / tool/tag.dart,
# which do not exist in this repo — removed 2026-09-02.

build-web-p:
	@APP_ENVIRONMENT=production bash deploy/build_flutter_web.sh

deploy-web-p: build-web-p
	@firebase deploy

build-web:
	@APP_ENVIRONMENT=staging bash deploy/build_flutter_web.sh

deploy-web: build-web
	@firebase hosting:channel:deploy staging --expires 30d

serve-web: build-web
	@firebase serve --only hosting -p 8080

# Native builds (the template pointed these at config/production.json, which never existed).
build-android:
	@flutter build apk --release --dart-define-from-file=config/production.env

build-windows:
	@flutter build windows --release --dart-define-from-file=config/production.env
