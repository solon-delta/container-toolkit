#!/bin/sh
set -e

CONTAINER_NAME="claude-code"
IMAGE_NAME="claude-code"

# Resolve persistent home (defaults to $HOME if DBX_CONTAINER_HOME_PREFIX is unset)
CONTAINER_HOME="${DBX_CONTAINER_HOME_PREFIX:-$HOME}/$CONTAINER_NAME"

# Auto-setup: create persistent directory if needed
mkdir -p "$CONTAINER_HOME"

# Rootless podman socket; override PODMAN_SOCK to use a different path.
PODMAN_SOCK="${PODMAN_SOCK:-/run/user/$(id -u)/podman/podman.sock}"

exec podman run --rm -it \
    -v "$CONTAINER_HOME:/root:Z" \
    -v "$(pwd):/workspace:Z" \
    ${PODMAN_SOCK:+-v "$PODMAN_SOCK:/run/podman/podman.sock:Z"} \
    ${PODMAN_SOCK:+-e "CONTAINER_HOST=unix:///run/podman/podman.sock"} \
    -e "HOST_WORKSPACE=$(pwd)" \
    "$IMAGE_NAME" "$@"
