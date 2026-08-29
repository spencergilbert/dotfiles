#!/usr/bin/env bash
set -euo pipefail

MISE_BIN="$HOME/.local/bin/mise"
REPO_DIR="$HOME/.dotfiles"

# Public, auth-free URL used only for the very first clone.
CLONE_URL="https://tangled.org/spencergilbert.dev/dotfiles"

# Where the repo is pulled from (canonical forge).
PULL_URL="git@tangled.org:did:plc:an5o2a52tfyhntuwsopwqnof"

# Every forge that `git push` should fan out to.
PUSH_URLS=(
  "$PULL_URL"
  "git@gitlab.com:spencergilbert/dotfiles.git"
  "git@github.com:spencergilbert/dotfiles.git"
)

# Point origin at the pull URL and mirror pushes to every forge above.
# Idempotent: re-running it resets pushurl entries instead of duplicating them.
configure_remotes() {
  if git -C "$REPO_DIR" remote get-url origin >/dev/null 2>&1; then
    git -C "$REPO_DIR" remote set-url origin "$PULL_URL"
  else
    git -C "$REPO_DIR" remote add origin "$PULL_URL"
  fi

  git -C "$REPO_DIR" config --unset-all remote.origin.pushurl || true
  for url in "${PUSH_URLS[@]}"; do
    git -C "$REPO_DIR" config --add remote.origin.pushurl "$url"
  done
  git -C "$REPO_DIR" config remote.pushdefault origin
}

if [ -d "$REPO_DIR/.git" ]; then
  configure_remotes
  # Forges reject pushes of shallow history; deepen if we were cloned with --depth.
  if [ -f "$REPO_DIR/.git/shallow" ]; then
    git -C "$REPO_DIR" fetch --unshallow origin || true
  fi
  git -C "$REPO_DIR" pull --rebase --autostash
else
  git clone --depth 1 "$CLONE_URL" "$REPO_DIR"
  configure_remotes
fi

command -v "$MISE_BIN" >/dev/null 2>&1 || curl -fsSL https://mise.run | sh

cd "$REPO_DIR"
"$MISE_BIN" trust "$REPO_DIR"
"$MISE_BIN" bootstrap --yes
