.PHONY: version doctor clean get fluttergen l10n l10n-translate build_runner codegen upgrade upgrade-major outdated dependencies format analyze check

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

# Generate localization from the Google Sheet (sheety_localization → gen-l10n), then verify the
# round trip. The sheet id is not repeated here: `tool/generate.dart` reads
# `packages/localization/l10n_tool.json`, the same file the offline gate reads.
# Requires packages/localization/credentials.json (service account; never committed).
L10N_MODEL ?= gpt-5.5
l10n:
	@cd packages/localization && dart run tool/generate.dart

# AI-fill the untranslated sheet cells (needs packages/localization/openai.key; never committed).
# Then run `make l10n` to pull + verify the result.
l10n-translate:
	@test -f packages/localization/openai.key || \
		{ echo "packages/localization/openai.key is missing — see README (Localization)"; exit 1; }
	@cd packages/localization && dart run tool/generate.dart --translate --model=$(L10N_MODEL)

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
