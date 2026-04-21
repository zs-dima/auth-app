.PHONY: gen-pubspec gen-build gen-build-delete gen-clean gen-watch doc

gen-pubspec:
	@echo "* Generating pubspec.yaml.g.dart *"
	@dart pub global activate pubspec_generator
	@dart pub global run pubspec_generator:generate -i pubspec.yaml -o lib/_core/generated/constant/pubspec.yaml.g.dart

gen-build: get gen-pubspec
	@echo "* Running build runner *"
	@dart run build_runner build

gen-build-delete: get gen-pubspec
	@echo "* Running build runner with deletion of conflicting outputs *"
	@dart run build_runner build --delete-conflicting-outputs

gen-clean:
	@echo "* Cleaning build runner *"
	@dart run build_runner clean

gen-watch:
	@echo "* Running build runner in watch mode *"
	@dart run build_runner watch

doc:
	@dart doc