#!/bin/sh
set -e

CONFIG_DEFAULTS="/usr/local/share/config/claude-code"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR"

# Symlink each top-level item from baked-in defaults into .claude/
# Skip anything that already exists (e.g., auth files from persistent volume)
for item in "$CONFIG_DEFAULTS"/*; do
    [ -e "$item" ] || continue
    name="$(basename "$item")"
    target="$CLAUDE_DIR/$name"
    if [ ! -e "$target" ]; then
        ln -s "$item" "$target"
    fi
done

exec "$@"
