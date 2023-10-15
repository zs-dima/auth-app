.PHONY: proto proto-lib proto-auth

proto: pub-get
	@echo "Running proto codegeneration"
	@fvm flutter pub global activate protoc_plugin
	@protoc -Iproto proto/**.proto -I package/model/grpc_model/proto --dart_out="grpc:lib/core/data/api/proto"
	@fvm dart format -l 120 --fix ./lib/core/data/api/proto

proto-lib: pub-get
	@echo "Running proto codegeneration"
	@fvm flutter pub global activate protoc_plugin
	@cd package/model/grpc_model && @protoc -Iproto proto/**.proto -Iproto proto/google/protobuf/**.proto --dart_out="grpc:lib/src/proto"
	@cd package/model/grpc_model && @fvm dart format -l 120 --fix lib/src/proto

proto-auth: pub-get
	@echo "Running proto codegeneration"
	@fvm flutter pub global activate protoc_plugin
	@cd package/model/auth_model && @protoc -Iproto proto/**.proto -I ../grpc_model/proto --dart_out="grpc:lib/src/api/proto"
	@cd package/model/auth_model && @fvm dart format -l 120 --fix lib/src/api/proto