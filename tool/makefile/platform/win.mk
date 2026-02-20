.PHONY: 

CFLAGS += -D win

# Idempotent recursive directory removal (like rm -rf on Unix)
# Usage: $(call RMDIR,path)
define RMDIR
	powershell -NoProfile -Command "Remove-Item -Recurse -Force -ErrorAction Ignore -Path '$(1)'; exit 0"
endef

_echo_os:
	@echo "Running Makefile on Windows"

