#!/usr/bin/env bash
set -euo pipefail

MISE_BIN="$HOME/.local/bin/mise"
REPO_URL="https://gitlab.com/spencergilbert/dotfiles.git"
REPO_DIR="$HOME/.dotfiles"

if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" pull --rebase --autostash
else
  git clone --depth 1 "$REPO_URL" "$REPO_DIR"
fi

command -v "$MISE_BIN" >/dev/null 2>&1 || curl -fsSL https://mise.run | sh

cd "$REPO_DIR"
"$MISE_BIN" trust "$REPO_DIR"
"$MISE_BIN" bootstrap --yes
