#!/bin/sh
set -e

# Install plugins that live in $HOME/.claude. This can't happen at image build time
# because $HOME/.claude is typically a volume mounted over the baked-in one at runtime.
if ! claude plugin list --json 2>/dev/null | jq -e 'any(.[]; .id == "ponytail@ponytail")' >/dev/null 2>&1; then
    claude plugin marketplace add DietrichGebert/ponytail || true
    claude plugin install ponytail@ponytail || true
fi