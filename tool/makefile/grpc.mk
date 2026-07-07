.PHONY: proto buf-lint buf-breaking buf-format buf-format-check \
       buf-gen buf-gen-core buf-gen-auth buf-gen-app buf-gen-rust buf-clean

# ==============================================================================
# Buf — protobuf toolchain
# https://buf.build
#
# Install:  scoop install buf  (Windows)
#           brew install bufbuild/buf/buf  (macOS)
#           npm install -g @bufbuild/buf   (via npm)
#
#           buf registry login
# ==============================================================================

BUF_PROTO_DIR := api/proto

# ---------------------------------------------------------------------------
# Lint / Format / Breaking
# ---------------------------------------------------------------------------

# Lint proto files (STANDARD rules)
buf-lint:
	@echo "Linting proto files"
	buf lint $(BUF_PROTO_DIR)

# Format proto files in-place
buf-format:
	@echo "Formatting proto files"
	buf format -w $(BUF_PROTO_DIR)

# Check formatting (CI — exits non-zero on diff)
buf-format-check:
	@echo "Checking proto formatting"
	buf format --diff --exit-code $(BUF_PROTO_DIR)

# Check for breaking changes against main branch
buf-breaking:
	@echo "Checking for breaking changes"
	buf breaking $(BUF_PROTO_DIR) --against ".git#branch=main,subdir=$(BUF_PROTO_DIR)"

# ---------------------------------------------------------------------------
# Clean
# ---------------------------------------------------------------------------

# Remove generated proto files (proxy files at auth_model .../proto/core/v1/ and
# .../proto/google/ are static source — see buf.gen.auth.yaml)
# NB: the previous `$(call RMDIR,…)` macro was never defined, so cleaning silently no-opped.
buf-clean:
	@echo "Cleaning generated proto files"
	@rm -rf packages/model/connect_model/lib/src/proto
	@rm -rf packages/model/auth_model/lib/src/proto/auth
	@rm -rf packages/model/auth_model/lib/src/proto/users
	@rm -rf lib/_core/data/api/proto

# ---------------------------------------------------------------------------
# Code generation — Dart (three targets for three Dart output packages)
# ---------------------------------------------------------------------------

# Generate core/v1 → packages/model/connect_model/lib/src/proto
buf-gen-core:
	@echo "Generating core proto (connect_model)"
	buf generate $(BUF_PROTO_DIR) --path $(BUF_PROTO_DIR)/core/v1 --template $(BUF_PROTO_DIR)/buf.gen.core.yaml
	dart format -l 120 packages/model/connect_model/lib/src/proto

# Generate auth/v1 + users/v1 → packages/model/auth_model/lib/src/proto
# Static proxy files at core/v1/ re-export types from connect_model (not generated)
buf-gen-auth:
	@echo "Generating auth + users proto (auth_model)"
	buf generate $(BUF_PROTO_DIR) --path $(BUF_PROTO_DIR)/auth/v1 --path $(BUF_PROTO_DIR)/users/v1 --template $(BUF_PROTO_DIR)/buf.gen.auth.yaml
	@rm -f packages/model/auth_model/lib/src/proto/auth/v1/*.pbserver.dart packages/model/auth_model/lib/src/proto/users/v1/*.pbserver.dart
	dart format -l 120 packages/model/auth_model/lib/src/proto

# Generate app/v1 → lib/_core/data/api/proto
buf-gen-app:
	@echo "Generating app proto"
	buf generate $(BUF_PROTO_DIR) --path $(BUF_PROTO_DIR)/app/v1 --template $(BUF_PROTO_DIR)/buf.gen.app.yaml
	@rm -f lib/_core/data/api/proto/app/v1/*.pbserver.dart
	dart format -l 120 lib/_core/data/api/proto

# ---------------------------------------------------------------------------
# Code generation — Rust (reference template for backend repos)
# ---------------------------------------------------------------------------

# Generate all protos → api/gen/rust (for local validation; not committed)
buf-gen-rust:
	@echo "Generating Rust proto stubs"
	buf generate $(BUF_PROTO_DIR) --template $(BUF_PROTO_DIR)/buf.gen.rust.yaml

# ---------------------------------------------------------------------------
# Aggregate targets
# ---------------------------------------------------------------------------

# Generate all Dart (clean first to remove stale files)
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