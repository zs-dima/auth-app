.PHONY: 

CFLAGS += -D nix

# Idempotent recursive directory removal
# Usage: $(call RMDIR,path)
define RMDIR
	rm -rf $(1)
endef

_echo_os:
	@echo "Running Makefile on *nix"

