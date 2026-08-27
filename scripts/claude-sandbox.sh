#!/bin/sh
set -e

export AGENT_NAME="claude-code"
export AGENT_IMAGE="claude-code"

exec "$(dirname "$0")/sandbox" "$@"
