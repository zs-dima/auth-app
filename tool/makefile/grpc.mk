.PHONY: proto proto-lib proto-auth

export PATH := a:/dev/packages/pub/bin;$(PATH)

proto: get
	@echo "Running proto codegeneration"
	@flutter pub global activate protoc_plugin
	@protoc -Iproto proto/**.proto -I package/model/grpc_model/proto --dart_out="grpc:lib/core/data/api/proto"
	@dart format -l 120 --fix ./lib/core/data/api/proto

proto-lib: get
	@echo "Running proto codegeneration"
	@flutter pub global activate protoc_plugin
	@cd package/model/grpc_model && @protoc -Iproto proto/**.proto -Iproto proto/google/protobuf/**.proto --dart_out="grpc:lib/src/proto"
	@cd package/model/grpc_model && @dart format -l 120 lib/src/proto

proto-auth: get
	@echo "Running proto codegeneration"
	@flutter pub global activate protoc_plugin
	@cd package/model/auth_model && @protoc -Iproto proto/**.proto -I ../grpc_model/proto --dart_out="grpc:lib/src/api/proto"
	@cd package/model/auth_model && @dart format -l 120 lib/src/api/proto