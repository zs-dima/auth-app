.PHONY: test test-root integration

# Tests across every workspace member that has a test/ directory, with a JSON report per
# package in reports/ (same layout CI's test-reporter consumes). Cross-platform Dart runner —
# no POSIX shell required.
test:
	@dart run tool/test_workspace.dart

# Root package only (the previous behavior)
test-root:
	@flutter test \
		--coverage \
		test/

integration:
	@flutter test \
		--coverage \
		integration_test/app_test.dart
