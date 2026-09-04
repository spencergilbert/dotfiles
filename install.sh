#!/usr/bin/env bash
set -euo pipefail

MISE_BIN="$HOME/.local/bin/mise"
REPO_DIR="$HOME/.dotfiles"

# Public, auth-free URL for the first clone and subsequent pulls.
# Pushes fan out to SSH mirrors via configure-forge-remotes
# ([bootstrap.hooks.final]).
FROM_URL="https://tangled.org/spencergilbert.dev/dotfiles"

command -v "$MISE_BIN" >/dev/null 2>&1 || curl -fsSL https://mise.run | sh

if [ -d "$REPO_DIR/.git" ]; then
  # Older checkouts pulled via SSH, which `mise bootstrap --from` rejects
  # as an origin mismatch — normalize once (idempotent thereafter).
  git -C "$REPO_DIR" remote set-url origin "$FROM_URL"
fi

"$MISE_BIN" bootstrap --from "$FROM_URL" --from-dir "$REPO_DIR" --update --yes
# `--from` trusts the checkout for that invocation only; persist it so later
# bare `mise` invocations don't prompt.
"$MISE_BIN" trust "$REPO_DIR"
