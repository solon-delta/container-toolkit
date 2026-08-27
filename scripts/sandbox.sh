#!/bin/sh
set -e

AGENT_NAME="${AGENT_NAME:?AGENT_NAME not set}"
AGENT_IMAGE="${AGENT_IMAGE:?AGENT_IMAGE not set}"

# Random suffix so multiple sandbox sessions can run in parallel without name clashes.
SUFFIX="$(od -An -N4 -tx4 /dev/urandom | tr -d ' \n')"
CONTAINER_NAME="$AGENT_NAME-$SUFFIX"

# Resolve persistent home (defaults to $HOME if DBX_CONTAINER_HOME_PREFIX is unset)
# Keyed by AGENT_NAME (not CONTAINER_NAME) so it persists across sessions.
CONTAINER_HOME="${DBX_CONTAINER_HOME_PREFIX:-$HOME}/$AGENT_NAME"

# Auto-setup: create persistent directories if needed
mkdir -p "$CONTAINER_HOME"
mkdir -p "$HOME/.config/gh"

# Rootless podman socket; override PODMAN_SOCK to use a different path.
PODMAN_SOCK="${PODMAN_SOCK:-/run/user/$(id -u)/podman/podman.sock}"

exec podman run --rm -it \
    --name "$CONTAINER_NAME" \
    -v "$CONTAINER_HOME:/root:Z" \
    -v "$(pwd):/workspace:Z" \
    -v "$HOME/.config/gh:/root/.config/gh:Z" \
    ${PODMAN_SOCK:+-v "$PODMAN_SOCK:/run/podman/podman.sock:Z"} \
    ${PODMAN_SOCK:+-e "CONTAINER_HOST=unix:///run/podman/podman.sock"} \
    -e "HOST_WORKSPACE=$(pwd)" \
    "$AGENT_IMAGE" "$@"