.PHONY: gen-build gen-build-delete gen-clean gen-watch doc

gen-build: get
	@echo "* Running build runner *"
	@fvm dart run build_runner build

gen-build-delete: get
	@echo "* Running build runner with deletion of conflicting outputs *"
	@fvm dart run build_runner build --delete-conflicting-outputs

gen-clean:
	@echo "* Cleaning build runner *"
	@fvm dart run build_runner clean

gen-watch:
	@echo "* Running build runner in watch mode *"
	@fvm dart run build_runner watch

doc:
	@fvm dart doc