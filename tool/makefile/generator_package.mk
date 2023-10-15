.PHONY: gen-lib gen-model

gen-lib: gen-model

gen-model: pub-get
	@echo "* Running auth_model build runner with deletion of conflicting outputs *"
	@cd package/model/auth_model && @fvm dart run build_runner build --delete-conflicting-outputs


