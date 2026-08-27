#!/bin/sh
set -e

export AGENT_NAME="pi"
export AGENT_IMAGE="pi"

exec "$(dirname "$0")/sandbox" "$@"
