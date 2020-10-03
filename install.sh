#!/usr/bin/env bash
#       _       _    __ _ _           
#    __| | ___ | |_ / _(_) | ___  ___ 
#   / _` |/ _ \| __| |_| | |/ _ \/ __|
#  | (_| | (_) | |_|  _| | |  __/\__ \
# (_)__,_|\___/ \__|_| |_|_|\___||___/
#

# Versions
ASDF_TAG="v0.8.0"

#     _    ____ _____ 
#    / \  |  _ \_   _|
#   / _ \ | |_) || |  
#  / ___ \|  __/ | |  
# /_/   \_\_|    |_|  
#

aptpkgs=(
	"fish"
	"git"
	"stow"
)
sudo apt-get update -qq
sudo apt-get install -qq -y "${aptpkgs[@]}"

#  _____ _       _               _    
# |  ___| | __ _| |_ _ __   __ _| | __
# | |_  | |/ _` | __| '_ \ / _` | |/ /
# |  _| | | (_| | |_| |_) | (_| |   < 
# |_|   |_|\__,_|\__| .__/ \__,_|_|\_\
#                   |_|       

flatpak install -y flathub com.discordapp.Discord
flatpak install -y flathub com.github.johnfactotum.Foliate
flatpak install -y flathub com.slack.Slack

#                _  __ 
#   __ _ ___  __| |/ _|
#  / _` / __|/ _` | |_ 
# | (_| \__ \ (_| |  _|
#  \__,_|___/\__,_|_|  
#                      

if [ ! -d "$HOME"/.asdf ]; then
	git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch $ASDF_TAG
fi
ASDF_BIN=$(which asdf)

"$ASDF_BIN" plugin-add golang https://github.com/kennyp/asdf-golang.git

#  ____  _                
# / ___|| |_ _____      __
# \___ \| __/ _ \ \ /\ / /
#  ___) | || (_) \ V  V / 
# |____/ \__\___/ \_/\_/  
#                         

if [ ! -d "$HOME"/.dotfiles ]; then
	git clone https://gitlab.com/spencergilbert/dotfiles.git "$HOME"/.dotfiles
fi
cd "$HOME/.dotfiles" || exit

stow fish
stow git
stow gnupg
stow ssh

#                   __ _                      
#   ___ ___  _ __  / _(_) __ _ _   _ _ __ ___ 
#  / __/ _ \| '_ \| |_| |/ _` | | | | '__/ _ \
# | (_| (_) | | | |  _| | (_| | |_| | | |  __/
#  \___\___/|_| |_|_| |_|\__, |\__,_|_|  \___|
#                        |___/                

sudo chsh -s $(which fish)

if [ ! -d "$HOME"/.config/fish ]; then
	mkdir -p "$HOME"/.config/fish
fi

cp -f "$HOME"/.asdf/completions/asdf.fish "$HOME"/.config/fish/completions

if [ ! -d "$HOME"/Code ]; then
	mkdir "$HOME"/Code
fi
