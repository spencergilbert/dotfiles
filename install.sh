#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "🔧 Installing dotfiles..."
echo ""

# 1Password not available in Fedora repos - add official repo
if ! rpm --query 1password &>/dev/null; then
	echo "📦 Setting up 1Password repository..."

	sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc

	cat <<'EOF' | sudo tee /etc/yum.repos.d/1password.repo >/dev/null
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF

	echo "✅ 1Password repository configured"
fi

echo ""
echo "📦 Installing packages..."
# shellcheck disable=SC2046
sudo dnf install --assumeyes $(grep --invert-match '^#' packages.txt | grep --invert-match '^$')

echo ""
echo "🔗 Stowing dotfiles..."
for pkg in stow/*/; do
	pkg_name=$(basename "$pkg")
	echo "  - $pkg_name"
	stow --dir=stow --target="$HOME" "$pkg_name"
done

echo ""
echo "🎨 Configuring GNOME..."
for conf in gnome/*.conf; do
	app_name=$(basename "$conf" .conf)

	if ! dconf list /org/gnome/ | grep --quiet "^${app_name}/$"; then
		echo "  ⚠️  Skipping $app_name - application not found"
		continue
	fi

	echo "  - $app_name"
	dconf load "/org/gnome/${app_name}/" <"$conf"
done

# Fish auto-launches from bash via .bashrc - no chsh needed
# See: stow/bash/.bashrc

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Installation complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Launch 1Password desktop app and sign in"
echo "   2. Enable SSH agent in 1Password settings"
echo "   3. Restart terminal (or run: exec bash)"
echo "   4. Fish will auto-launch from bash"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
