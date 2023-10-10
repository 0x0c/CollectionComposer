# Variables

.DEFAULT_GOAL := help

# Targets

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?# .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":[^#]*? #| #"}; {printf "%-42s%s\n", $$1 $$3, $$2}'

.PHONY: bootstrap
bootstrap: # Setup tools
	mint bootstrap

.PHONY: format
format: # Format code
	mint run swiftformat ./Sources/
	mint run swiftformat ./Tests/
	mint run swiftformat Package.swift
	mint run swiftformat ./Examples/

.PHONY: lint
lint: # Lint code
	mint run swiftlint autocorrect
