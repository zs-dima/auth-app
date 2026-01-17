.PHONY: gen-lib gen-model

gen-lib: gen-model
gen-model: get
	@echo "* Running auth_model build runner with deletion of conflicting outputs *"
	@cd packages/model/auth_model && @fvm dart run build_runner build --delete-conflicting-outputs --release
