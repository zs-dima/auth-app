.PHONY: version doctor clean get fluttergen l10n build_runner codegen upgrade upgrade-major outdated dependencies format analyze check

# Check flutter version
version:
	@flutter --version

# Check flutter doctor
doctor:
	@flutter doctor

# Clean all generated files
clean:
	@rm -rf coverage .dart_tool .packages pubspec.lock
	@(rm -rf coverage .dart_tool .packages pubspec.lock)

# Get dependencies
get:
	@flutter pub get

# Generate assets
fluttergen:
	@dart pub global activate flutter_gen
	@fluttergen -c pubspec.yaml

# Generate localization from the Google Sheet (sheety_localization → gen-l10n).
# Requires packages/localization/credentials.json (service account; never committed).
SHEET_ID ?= 1FAbQS3nA5czjBBayC3ms-DqkkdskCPLtrh2FDZ1P0lg
l10n:
	@test -f packages/localization/credentials.json || \
		{ echo "packages/localization/credentials.json is missing — see README (Localization)"; exit 1; }
	@cd packages/localization && \
		dart run sheety_localization:generate -c credentials.json -s $(SHEET_ID) --prefix=app --format --include-empty && \
		dart run tool/verify_l10n.dart

# Build runner
build_runner:
	@dart run build_runner build --delete-conflicting-outputs --release

# Generate pubspec constant
pubspec:
	@dart pub global activate pubspec_generator
	@dart pub global run pubspec_generator:generate --input pubspec.yaml --output lib/_core/generated/constant/pubspec.yaml.g.dart

# Generate code
# NB: l10n is NOT in the chain — its output is committed and regenerating needs Google
# credentials; run `make l10n` explicitly after editing the localization sheet.
codegen: get fluttergen pubspec build_runner format

fix: format
	@dart fix --apply lib

# Generate all
gen: codegen

# Upgrade dependencies
upgrade:
	@flutter pub upgrade

# Upgrade to major versions
upgrade-major:
	@flutter pub upgrade --major-versions

# Check outdated dependencies
outdated: get
	@flutter pub outdated

# Check outdated dependencies
dependencies: upgrade
	@flutter pub outdated --dependency-overrides \
		--dev-dependencies --prereleases --show-all --transitive

# Format code (page_width comes from analysis_options.yaml; `--fix` was removed from dart format)
format:
	@dart format .


# Analyze code
analyze: get format
	@dart analyze --fatal-infos --fatal-warnings

# Check code
check: analyze
	@dart pub publish --dry-run
	@dart pub global activate pana
	@pana --json --no-warning --line-length 120 > log.pana.json

# Publish package
publish:
	@dart pub publish
