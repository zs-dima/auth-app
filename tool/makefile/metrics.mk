.PHONY: dcm dcm-fix dcm-unused-code dcm-unused-files dcm-unused-l10n stats dependency-validator pana

# DCM (configured in `lints_tool`, a git dependency: github.com/zs-dima/lints_tool). The template's targets here called
# `grind code-metrics-*`, and this repo has no tool/grind.dart — they could never have run.
#
# Scope is the whole repo, not just lib/: the tests and tool scripts are code we maintain, and
# DCM's test rules (prefer-test-matchers, avoid-top-level-members-in-tests) are the reason to
# have it pointed at them.
dcm:
	@dcm analyze .

# Applies the mechanical fixes — dot shorthands, test matchers and the like. Review the diff:
# `dcm fix` is not a formatter and does change semantics in a few rules.
dcm-fix:
	@dcm fix .

dcm-unused-code:
	@dcm check-unused-code . --fatal-unused

dcm-unused-files:
	@dcm check-unused-files . --fatal-unused

# ARB keys nothing reads. Generated l10n is committed, so this is meaningful here.
dcm-unused-l10n:
	@dcm check-unused-l10n . --fatal-unused

stats:
	@echo "* Running cloc *"
	@cloc .

# https://pub.dev/packages/dependency_validator
dependency-validator:
	@dart run dependency_validator

pana:
	@dart pub global activate pana && pana --json --no-warning --line-length 120
