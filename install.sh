#!/usr/bin/env bash
aptpkgs=(
	"alacritty" 
	"autoconf"
	"build-essential"
	"chromium-browser"
	"clang"
	"docker.io"
	"git"
	"htop"
	"inotify-tools"
	"jq"
	"libncurses5-dev"
	"libssl-dev"
	"neovim"
	"stow"
	"tmux"
	"zsh"
)
crates=(
	"exa"
	"bat"
	"fd-find"
	"git-delta"
	"ripgrep"
	"skim"
	"starship"
)
ASDF_TAG="v0.7.8"
ASDF_BIN="$HOME/.asdf/bin/asdf"

## apt
sudo apt-get update -qq
sudo apt-get install -qq -y "${aptpkgs[@]}"

## flatpak
flatpak install -y flathub com.github.johnfactotum.Foliate

## asdf
if [ ! -d "$HOME"/.asdf ]; then
	git clone https://github.com/asdf-vm/asdf.git "$HOME"/.asdf --branch $ASDF_TAG
fi

"$ASDF_BIN" plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
"$ASDF_BIN" plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
"$ASDF_BIN" plugin-add golang https://github.com/kennyp/asdf-golang.git
"$ASDF_BIN" plugin-add helm https://github.com/Antiarchitect/asdf-helm.git
"$ASDF_BIN" plugin-add kind https://github.com/johnlayton/asdf-kind.git
"$ASDF_BIN" plugin-add kubectl https://github.com/Banno/asdf-kubectl.git
"$ASDF_BIN" plugin-add kustomize https://github.com/Banno/asdf-kustomize.git
"$ASDF_BIN" plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
"$ASDF_BIN" plugin-add protoc https://github.com/paxosglobal/asdf-protoc.git
"$ASDF_BIN" plugin-add rust https://github.com/code-lever/asdf-rust.git
"$ASDF_BIN" plugin-add terraform https://github.com/Banno/asdf-hashicorp.git

## add node's GPG keys
/bin/bash "$HOME"/.asdf/plugins/nodejs/bin/import-release-team-keyring

"$HOME"/.asdf/bin/asdf install rust stable
"$HOME"/.asdf/bin/asdf global rust stable

for i in "${crates[@]}"; do cargo install "$i"; done

"$HOME"/.asdf/bin/asdf reshim rust

## antibody
curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin

## stow dotfiles
if [ ! -d "$HOME"/.dotfiles ]; then
	git clone https://gitlab.com/spencergilbert/dotfiles.git "$HOME"/.dotfiles
fi

cd "$HOME/.dotfiles" || exit

stow alacritty
sudo stow bin -t /usr/local/bin
stow fonts
stow git
stow gnupg
stow ssh
stow starship
stow tmux
stow vim
stow zsh

## configuration
sudo chsh -s "$(which zsh)" "$USER"

## load zsh pluings
antibody bundle < "$HOME"/.zsh_plugins.txt > "$HOME"/.zsh_plugins.sh

## prepare Docker
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

if [ ! -d "$HOME"/Code ]; then
	mkdir "$HOME"/Code
fi
