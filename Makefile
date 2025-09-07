#!/usr/bin/make -f

.PHONY: help install uninstall test lint clean deps

help:
	@echo "Linux Toolkit - Available commands:"
	@echo "  make install    - Install scripts to ~/bin"
	@echo "  make uninstall  - Remove scripts from ~/bin"
	@echo "  make test       - Run basic smoke tests"
	@echo "  make lint       - Run shellcheck on all scripts"
	@echo "  make clean      - Clean temporary files"
	@echo "  make deps       - Install required dependencies"

install:
	@echo "Installing to ~/bin..."
	@mkdir -p ~/bin
	@cp -r lib ~/bin/linux-toolkit-lib
	@find . -name "*.sh" -type f | while read script; do \
		[ -x "$$script" ] || { echo "Warning: $$script not executable"; continue; }; \
		bash -n "$$script" || { echo "Error: $$script has syntax errors"; exit 1; }; \
		name=$$(basename "$$script" .sh); \
		cp "$$script" ~/bin/linux-toolkit-"$$name" || { echo "Error: failed to copy $$script"; exit 1; }; \
		chmod +x ~/bin/linux-toolkit-"$$name"; \
	done
	@echo "Installation complete. Add ~/bin to PATH if needed."

uninstall:
	@echo "Uninstalling from ~/bin..."
	@rm -rf ~/bin/linux-toolkit-lib
	@rm -f ~/bin/linux-toolkit-*
	@echo "Uninstallation complete."

test:
	@echo "Running smoke tests..."
	@for script in $$(find . -name "*.sh" -type f -executable); do \
		echo "Testing $$script..."; \
		bash -n "$$script" || exit 1; \
	done
	@echo "All scripts pass syntax check."

lint:
	@echo "Running shellcheck..."
	@shellcheck $$(find . -name "*.sh" -type f)

deps:
	@echo "Installing dependencies..."
	@command -v shellcheck >/dev/null || { echo "Installing shellcheck..."; \
		if command -v apt >/dev/null; then sudo apt install -y shellcheck; \
		elif command -v yum >/dev/null; then sudo yum install -y ShellCheck; \
		elif command -v brew >/dev/null; then brew install shellcheck; \
		else echo "Please install shellcheck manually"; exit 1; fi; }
	@command -v docker >/dev/null || echo "Warning: docker not found - docker scripts will not work"
	@command -v speedtest-cli >/dev/null || echo "Info: speedtest-cli will be installed when needed"
	@echo "Dependencies check complete."

clean:
	@echo "Cleaning temporary files..."
	@find . -name "*.tmp" -delete
	@find . -name "*~" -delete