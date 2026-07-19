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

# Configure git to push to GitHub over HTTPS using the already-mounted gh token.
# Avoids needing any SSH key/agent inside the sandbox.
if gh auth status >/dev/null 2>&1; then
    gh auth setup-git >/dev/null 2>&1 || true
    # Route existing SSH-style GitHub remotes through HTTPS so they use the token too.
    git config --global --replace-all url."https://github.com/".insteadOf "git@github.com:"
    git config --global --add url."https://github.com/".insteadOf "ssh://git@github.com/"
fi

exec "$@"
