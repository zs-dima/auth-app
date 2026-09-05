ifeq ($(OS),Windows_NT)
	include tool/makefile/platform/win.mk
else
    _detected_OS := $(shell uname -s)
    # Optional (-include): nix-shared.mk does not exist in this repo; a hard `include` of a
    # missing file aborts every make invocation on Linux/macOS.
    -include tool/makefile/platform/nix-shared.mk
    ifeq ($(_detected_OS),Linux)
		include tool/makefile/platform/nix.mk
    else ifeq ($(_detected_OS),Darwin)
		include tool/makefile/platform/mac.mk
    endif
endif