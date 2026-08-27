#!/bin/sh
set -e

CONFIG_DEFAULTS="${AGENT_CONFIG_DEFAULTS:?AGENT_CONFIG_DEFAULTS not set}"
TARGET_DIR="${AGENT_TARGET_DIR:?AGENT_TARGET_DIR not set}"
SETTINGS_NAME="${AGENT_SETTINGS_NAME:-settings.json}"

mkdir -p "$TARGET_DIR"

# Symlink each top-level item from baked-in defaults into $TARGET_DIR/.
# Skip anything that already exists (e.g., auth/session files from a persistent
# volume). The settings file is excluded -- it's merged (not symlinked) below.
for item in "$CONFIG_DEFAULTS"/*; do
    [ -e "$item" ] || continue
    name="$(basename "$item")"
    [ "$name" = "$SETTINGS_NAME" ] && continue
    target="$TARGET_DIR/$name"
    if [ ! -e "$target" ]; then
        ln -s "$item" "$target"
    fi
done

# Merge baked-in default settings into the live one instead of symlinking, so
# image updates to defaults keep reaching users who already have a live settings
# file on their persistent volume. User defaults win on conflict; objects merge
# recursively and arrays are unioned+deduped so re-running this on every
# container start stays idempotent.
DEFAULT_SETTINGS="$CONFIG_DEFAULTS/$SETTINGS_NAME"
LIVE_SETTINGS="$TARGET_DIR/$SETTINGS_NAME"
if [ -f "$DEFAULT_SETTINGS" ]; then
    if [ -f "$LIVE_SETTINGS" ]; then
        tmp="$(mktemp "$TARGET_DIR/$SETTINGS_NAME.XXXXXX")"
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
        # mv (not shell redirection) so a pre-existing settings file that is
        # itself a symlink gets replaced, not written through.
        mv "$tmp" "$LIVE_SETTINGS"
    else
        cp "$DEFAULT_SETTINGS" "$LIVE_SETTINGS"
    fi
fi

# Caller-specific setup hook (e.g., a path to a plugin-install script that needs
# $TARGET_DIR at runtime because it's a volume mounted over the baked-in one).
if [ -n "$AGENT_SETUP_HOOK" ]; then
    eval "$AGENT_SETUP_HOOK"
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
