.PHONY: proto proto-lib proto-auth proto-activate

export PATH := a:/dev/packages/pub/bin;$(PATH)

proto-activate:
	@echo "Activating protoc_plugin"
	@dart pub global deactivate protoc_plugin 2>nul || true
	@dart pub global activate protoc_plugin

proto: get proto-activate
	@echo "Running proto codegeneration"
	@protoc -Iproto proto/**.proto -I packages/model/grpc_model/proto --dart_out="grpc:lib/_core/data/api/proto"
	@dart format -l 120 --fix ./lib/_core/data/api/proto

proto-lib: get proto-activate
	@echo "Running proto codegeneration"
	@cd packages/model/grpc_model && protoc -Iproto proto/**.proto --dart_out="grpc:lib/src/proto"
	@cd packages/model/grpc_model && dart format -l 120 lib/src/proto

proto-auth: get proto-activate
	@echo "Running proto codegeneration"
	@cd packages/model/auth_model && protoc -Iproto proto/**.proto -I ../grpc_model/proto --dart_out="grpc:lib/src/api/proto"
	@cd packages/model/auth_model && dart format -l 120 lib/src/api/proto