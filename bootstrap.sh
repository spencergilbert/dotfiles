#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Bootstrapping dotfiles..."
echo ""

# Check for DNF (Fedora, RHEL 8+, CentOS Stream, etc.)
if ! command -v dnf &>/dev/null; then
	echo "❌ Error: This script requires DNF package manager"
	echo "   (Fedora, RHEL 8+, CentOS Stream, etc.)"
	exit 1
fi

if ! command -v git &>/dev/null; then
	echo "📦 Installing git..."
	sudo dnf install --assumeyes git
fi

# Clone to ~/.dotfiles for cleaner stow targeting
DOTFILES_DIR="$HOME/.dotfiles"

if [[ ! -d "$DOTFILES_DIR" ]]; then
	echo "📥 Cloning dotfiles repository..."
	git clone https://github.com/spencergilbert/dotfiles.git "$DOTFILES_DIR"
else
	echo "✅ Repository already exists"
	cd "$DOTFILES_DIR"
	git pull --ff-only || true
fi

cd "$DOTFILES_DIR"

echo ""
echo "📦 Updating system packages..."
sudo dnf upgrade --assumeyes

echo ""
./install.sh

# Convert remote to SSH for 1Password agent
echo ""
echo "🔄 Converting git remote to SSH..."

current_url=$(git remote get-url origin)

if [[ "$current_url" == https://github.com/* ]]; then
	repo_path=$(echo "$current_url" | sed 's#https://github.com/##' | sed 's#\.git$##')
	ssh_url="git@github.com:${repo_path}.git"

	git remote set-url origin "$ssh_url"
	echo "✅ Remote updated to SSH (will work after 1Password setup)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Bootstrap complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
