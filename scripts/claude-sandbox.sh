#!/bin/sh
set -e

CONTAINER_NAME="claude-code"
IMAGE_NAME="claude-code"

# Resolve persistent home (defaults to $HOME if DBX_CONTAINER_HOME_PREFIX is unset)
CONTAINER_HOME="${DBX_CONTAINER_HOME_PREFIX:-$HOME}/$CONTAINER_NAME"

# Auto-setup: create persistent directory if needed
mkdir -p "$CONTAINER_HOME"

exec podman run --rm -it \
    -v "$CONTAINER_HOME:/root:Z" \
    -v "$(pwd):/workspace:Z" \
    "$IMAGE_NAME" "$@"
