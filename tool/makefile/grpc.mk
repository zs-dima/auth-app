.PHONY: proto buf-lint buf-breaking buf-gen buf-gen-core buf-gen-auth buf-gen-app buf-clean

# ==============================================================================
# Buf — protobuf toolchain (replaces protoc + protoc_plugin)
# https://buf.build
#
# Install:  scoop install buf  (Windows)
#           brew install bufbuild/buf/buf  (macOS)
#           npm install -g @bufbuild/buf   (via npm)
# 
#           buf registry login
# ==============================================================================

BUF_PROTO_DIR := api/proto

# Lint proto files (STANDARD rules)
buf-lint:
	@echo "Linting proto files"
	buf lint $(BUF_PROTO_DIR)

# Check for breaking changes against main branch
buf-breaking:
	@echo "Checking for breaking changes"
	buf breaking $(BUF_PROTO_DIR) --against ".git#branch=main,subdir=$(BUF_PROTO_DIR)"

# Remove generated proto files (proxy files at auth_model/core/v1/ are static source)
buf-clean:
	@echo "Cleaning generated proto files"
	$(call RMDIR,packages/model/grpc_model/lib/src/proto)
	$(call RMDIR,packages/model/auth_model/lib/src/api/proto/auth)
	$(call RMDIR,packages/model/auth_model/lib/src/api/proto/users)
	$(call RMDIR,lib/_core/data/api/proto)

# ---------------------------------------------------------------------------
# Code generation — three targets for three Dart output packages
# ---------------------------------------------------------------------------

# Generate core/v1 → packages/model/grpc_model/lib/src/proto
buf-gen-core:
	@echo "Generating core proto (grpc_model)"
	cd $(BUF_PROTO_DIR) && buf generate . --path core/v1 --template buf.gen.core.yaml
	dart format -l 120 packages/model/grpc_model/lib/src/proto

# Generate auth/v1 + users/v1 → packages/model/auth_model/lib/src/api/proto
# Static proxy files at core/v1/ re-export types from grpc_model (not generated)
buf-gen-auth:
	@echo "Generating auth + users proto (auth_model)"
	cd $(BUF_PROTO_DIR) && buf generate . --path auth/v1 --path users/v1 --template buf.gen.auth.yaml
	dart format -l 120 packages/model/auth_model/lib/src/api/proto

# Generate app/v1 → lib/_core/data/api/proto
buf-gen-app:
	@echo "Generating app proto"
	cd $(BUF_PROTO_DIR) && buf generate . --path app/v1 --template buf.gen.app.yaml
	dart format -l 120 lib/_core/data/api/proto

# Generate all (clean first to remove stale files)
buf-gen: buf-clean buf-gen-core buf-gen-auth buf-gen-app
	@echo "All proto generation complete"

proto: buf-gen

# .PHONY: proto proto-lib proto-auth proto-activate

# export PATH := a:/dev/packages/pub/bin;$(PATH)

# proto-activate:
# 	@echo "Activating protoc_plugin"
# 	@dart pub global deactivate protoc_plugin 2>nul || true
# 	@dart pub global activate protoc_plugin

# proto: get proto-activate
# 	@echo "Running proto codegeneration"
# 	@protoc -Iproto proto/**.proto -I packages/model/grpc_model/proto --dart_out="grpc:lib/_core/data/api/proto"
# 	@dart format -l 120 --fix ./lib/_core/data/api/proto

# proto-lib: get proto-activate
# 	@echo "Running proto codegeneration"
# 	@cd packages/model/grpc_model && protoc -Iproto proto/**.proto --dart_out="grpc:lib/src/proto"
# 	@cd packages/model/grpc_model && dart format -l 120 lib/src/proto

# proto-auth: get proto-activate
# 	@echo "Running proto codegeneration"
# 	@cd packages/model/auth_model && protoc -Iproto proto/**.proto -I ../grpc_model/proto --dart_out="grpc:lib/src/api/proto"
# 	@cd packages/model/auth_model && dart format -l 120 lib/src/api/proto	