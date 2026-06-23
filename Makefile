.PHONY: help create-office destroy-office

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# --- Distrobox containers ---

create-office: ## Create the office distrobox container
	distrobox assemble create --file containers/office/distrobox.ini

destroy-office: ## Destroy the office distrobox container
	distrobox assemble rm --file containers/office/distrobox.ini

# --- Podman containers ---
# Example target for a future podman container:
#
# build-<name>: ## Build the <name> podman image
# 	podman build -t <name> \
# 		-f containers/<name>/Containerfile \
# 		--build-arg COMMON_DIR=common_dotfiles \
# 		.
#
# run-<name>: ## Run the <name> podman container
# 	podman run --rm -it -v $$(pwd):/workspace:Z <name>
