.PHONY: build-web deploy-web build-web-p deploy-web-p serve-web build-android build-windows release-staging release-production

changes-staging: 
	fvm dart run tool/changes.dart --release beta

changes-production: 
	fvm dart run tool/changes.dart --release prod

release-staging: 
	fvm dart run tool/tag.dart --release --dart-define=ENVIRONMENT=staging

release-production: 
	fvm dart run tool/tag.dart --release --dart-define=ENVIRONMENT=production

build-web-p:
	@fvm flutter build web --release --dart-define-from-file=config/production.env --no-source-maps --wasm --no-web-resources-cdn --tree-shake-icons --base-href /

deploy-web-p: build-web-p
	@firebase deploy

build-web:
	@fvm flutter build web --release --dart-define-from-file=config/staging.env --no-source-maps --wasm --no-web-resources-cdn --tree-shake-icons --base-href /

deploy-web: build-web
	@firebase hosting:channel:deploy staging --expires 30d

# https://docs.flutter.dev/platform-integration/web/wasm
#build-web-wasm:
#	@fvm spawn main build web --wasm --release --dart-define-from-file=config/development.json --no-source-maps --pwa-strategy offline-first --no-web-resources-cdn --base-href /
#	@fvm flutter build web --wasm --release --dart-define-from-file=config/production.json --no-source-maps --pwa-strategy offline-first --no-web-resources-cdn --base-href /

#deploy-web-wasm: build-web-wasm
#	@firebase hosting:channel:deploy wasm --expires 14d

serve-web: build-web
	@firebase serve --only hosting -p 8080

build-android:
	@flutter build apk --release --dart-define-from-file=config/production.json

build-windows:
	@flutter build windows --release --dart-define-from-file=config/production.json
