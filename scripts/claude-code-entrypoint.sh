#!/bin/sh
set -e

CONFIG_DEFAULTS="/usr/local/share/config/claude-code"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR"

# Symlink each top-level item from baked-in defaults into .claude/
# Skip anything that already exists (e.g., auth files from persistent volume)
# settings.json is excluded here -- it's merged (not symlinked) below.
for item in "$CONFIG_DEFAULTS"/*; do
    [ -e "$item" ] || continue
    name="$(basename "$item")"
    [ "$name" = "settings.json" ] && continue
    target="$CLAUDE_DIR/$name"
    if [ ! -e "$target" ]; then
        ln -s "$item" "$target"
    fi
done

# Merge baked-in default settings.json into the live one instead of
# symlinking, so image updates to defaults keep reaching users who already
# have a live settings.json on their persistent volume. Usr defaults win on
# conflict; objects merge recursively and arrays are unioned+deduped so
# re-running this on every container start stays idempotent.
DEFAULT_SETTINGS="$CONFIG_DEFAULTS/settings.json"
LIVE_SETTINGS="$CLAUDE_DIR/settings.json"
if [ -f "$DEFAULT_SETTINGS" ]; then
    if [ -f "$LIVE_SETTINGS" ]; then
        tmp="$(mktemp "$CLAUDE_DIR/settings.json.XXXXXX")"
        jq -s '
            def deepmerge($a; $b):
                if ($a | type) == "object" and ($b | type) == "object" then
                    reduce ((($a | keys_unsorted) + ($b | keys_unsorted) | unique)[]) as $k
                        ({}; .[$k] =
                            if ($a | has($k)) and ($b | has($k)) then deepmerge($a[$k]; $b[$k])
                            elif ($b | has($k)) then $b[$k]
                            else $a[$k] end)
                elif ($a | type) == "array" and ($b | type) == "array" then
                    ($a + $b) | unique
                else
                    $b
                end;
            deepmerge(.[0]; .[1])
        ' "$LIVE_SETTINGS" "$DEFAULT_SETTINGS" > "$tmp"
        # mv (not shell redirection) so a pre-existing settings.json that is
        # itself a symlink gets replaced, not written through.
        mv "$tmp" "$LIVE_SETTINGS"
    else
        cp "$DEFAULT_SETTINGS" "$LIVE_SETTINGS"
    fi
fi

# Install plugins that live in $HOME/.claude. This can't happen at image build time
# because $HOME/.claude is typically a volume mounted over the baked-in one at runtime.
if ! claude plugin list --json 2>/dev/null | jq -e 'any(.[]; .id == "ponytail@ponytail")' >/dev/null 2>&1; then
    claude plugin marketplace add DietrichGebert/ponytail || true
    claude plugin install ponytail@ponytail || true
fi

# Configure git to push to GitHub over HTTPS using the already-mounted gh token.
# Avoids needing any SSH key/agent inside the sandbox.
if gh auth status >/dev/null 2>&1; then
    gh auth setup-git >/dev/null 2>&1 || true
    # Route existing SSH-style GitHub remotes through HTTPS so they use the token too.
    git config --global --replace-all url."https://github.com/".insteadOf "git@github.com:"
    git config --global --add url."https://github.com/".insteadOf "ssh://git@github.com/"
fi

exec "$@"
