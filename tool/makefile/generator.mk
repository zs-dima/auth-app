.PHONY: gen-build gen-build-delete gen-clean gen-watch doc

gen-build: get
	@echo "* Running build runner *"
	@fvm dart pub global activate pubspec_generator
	@fvm dart run build_runner build
	@fvm dart pub global run pubspec_generator:generate -o lib/_core/generated/constant/pubspec.yaml.g.dart

gen-build-delete: get
	@echo "* Running build runner with deletion of conflicting outputs *"
	@fvm dart pub global activate pubspec_generator
	@fvm dart run build_runner build --delete-conflicting-outputs
	@fvm dart pub global run pubspec_generator:generate -o lib/_core/generated/constant/pubspec.yaml.g.dart

gen-clean:
	@echo "* Cleaning build runner *"
	@fvm dart run build_runner clean

gen-watch:
	@echo "* Running build runner in watch mode *"
	@fvm dart run build_runner watch

doc:
	@fvm dart doc