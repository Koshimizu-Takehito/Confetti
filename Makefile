.PHONY: setup sync lint lint-fix lint-strict format format-check fix test build clean open open-example help

# Default target
.DEFAULT_GOAL := help

# ============================================================================
# Setup
# ============================================================================

setup: ## Install Mint (if needed) and dependencies via Mint
	@echo "📦 Checking Mint installation..."
	@if ! command -v mint >/dev/null 2>&1; then \
		if command -v brew >/dev/null 2>&1; then \
			echo "🍺 Mint not found. Installing via Homebrew..."; \
			brew install mint; \
		else \
			echo "❌ Mint is not installed and Homebrew is not available."; \
			echo "   Please install Mint manually: https://github.com/yonaskolb/Mint"; \
			exit 1; \
		fi; \
	fi
	@echo "📦 Installing packages from Mintfile..."
	@mint bootstrap
	@echo "✅ Setup complete!"

sync: ## Pull latest changes and update all dependencies
	@echo "🔄 Pulling latest changes..."
	@git pull
	@echo "📦 Updating Mint packages..."
	@mint bootstrap
	@echo "📦 Resolving Swift packages..."
	@swift package resolve
	@echo "✅ Sync complete!"

# ============================================================================
# Linting & Formatting
# ============================================================================

lint: ## Run SwiftLint
	@echo "🔍 Running SwiftLint..."
	@mint run swiftlint lint

lint-fix: ## Run SwiftLint with auto-correction
	@echo "🔧 Running SwiftLint auto-fix..."
	@mint run swiftlint lint --fix
	@echo "✅ Auto-fix complete!"

lint-strict: ## Run SwiftLint treating warnings as errors (for CI)
	@echo "🔍 Running SwiftLint (strict mode)..."
	@mint run swiftlint lint --strict

format: ## Format code with SwiftFormat
	@echo "✨ Formatting code..."
	@mint run swiftformat Sources Tests Example
	@echo "✅ Formatting complete!"

format-check: ## Check code formatting (no changes)
	@echo "🔍 Checking code format..."
	@mint run swiftformat Sources Tests Example --lint

fix: format lint-fix ## Format and auto-fix all code
	@echo "✅ All fixes applied!"

# ============================================================================
# Build & Test
# ============================================================================

build: ## Build the package
	@echo "🔨 Building..."
	@swift build

test: ## Run tests
	@echo "🧪 Running tests..."
	@swift test

# ============================================================================
# CI
# ============================================================================

ci: lint format-check test ## Run all CI checks (lint, format-check, test)
	@echo "✅ All CI checks passed!"

# ============================================================================
# Utilities
# ============================================================================

open: ## Open package in Xcode
	@xed .

open-example: ## Open example project in Xcode
	@xed Example

clean: ## Clean build artifacts
	@echo "🧹 Cleaning..."
	@swift package clean
	@rm -rf .build
	@echo "✅ Clean complete!"

# ============================================================================
# Help
# ============================================================================

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
