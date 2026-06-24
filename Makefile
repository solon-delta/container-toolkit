.PHONY: help create-distrobox destroy-distrobox build-podman install-podman

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# --- Distrobox containers ---

create-distrobox:
	distrobox assemble create --file containers/office/distrobox.ini

destroy-distrobox:
	distrobox assemble rm --file containers/office/distrobox.ini

# --- Podman containers ---

build-podman:
	podman build -t claude-code \
		-f containers/claude-code/Containerfile \
		.

install-podman: ## Install wrapper to ~/.local/bin
	install -Dm755 scripts/claude-sandbox.sh $(HOME)/.local/bin/claude-sandbox
