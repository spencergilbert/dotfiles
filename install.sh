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
	"alacritty"
	"build-essential"
	"curl"
	"fish"
	"git"
	"libssl-dev"
	"stow"
)
sudo apt-get update -qq
sudo apt-get install -qq -y "${aptpkgs[@]}"

curl --proto '=https' --tlsv1.2 -sSf https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /tmp/chrome.deb
sudo apt install -qq -y /tmp/chrome.deb

#  _____ _       _               _    
# |  ___| | __ _| |_ _ __   __ _| | __
# | |_  | |/ _` | __| '_ \ / _` | |/ /
# |  _| | | (_| | |_| |_) | (_| |   < 
# |_|   |_|\__,_|\__| .__/ \__,_|_|\_\
#                   |_|       

flatpak install -y --or-update flathub com.discordapp.Discord
flatpak install -y --or-update flathub com.github.johnfactotum.Foliate
flatpak install -y --or-update flathub com.slack.Slack

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

#   ____           _            
#  / ___|_ __ __ _| |_ ___  ___ 
# | |   | '__/ _` | __/ _ \/ __|
# | |___| | | (_| | ||  __/\__ \
#  \____|_|  \__,_|\__\___||___/
#                               

crates=(
	"bandwhich"
	"bat"
	"bottom"
	"du-dust"
	"exa"
	"fd-find"
	"git-delta"
	"gitui"
	"grex"
	"hyperfine"
	"mdcat"
	"procs"
	"rargs"
	"ripgrep"
	"rmesg"
	"sd"
	"skim"
	"starship"
	"tealdeer"
	"tokei"
	"topgrade"
	"watchexec"
	"zoxide"
)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# shellcheck source=/dev/null
source "$HOME"/.cargo/env
for i in "${crates[@]}"; do cargo install "$i"; done

# bandwhich needs additional capabilities to run without 'sudo'
sudo setcap cap_sys_ptrace,cap_dac_read_search,cap_net_raw,cap_net_admin+ep "$(which bandwhich)"

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
stow starship

#                   __ _                      
#   ___ ___  _ __  / _(_) __ _ _   _ _ __ ___ 
#  / __/ _ \| '_ \| |_| |/ _` | | | | '__/ _ \
# | (_| (_) | | | |  _| | (_| | |_| | | |  __/
#  \___\___/|_| |_|_| |_|\__, |\__,_|_|  \___|
#                        |___/                

if [ ! -d "$HOME"/Code ]; then
	mkdir "$HOME"/Code
fi

#                  ___
#   ___======____=---=)
# /T            \_--===)
# [ \ (O)   \~    \_-==)
#  \      / )J~~    \-=)
#   \\___/  )JJ~~~   \)
#    \_____/JJJ~~~~    \
#    / \  , \J~~~~~     \
#   (-\)\=|\\\~~~~       L__
#   (\\)  (\\\)_           \==__
#    \V    \\\) ===_____   \\\\\\
#           \V)     \_) \\\\JJ\J\)
#                       /J\JT\JJJJ)
#                       (JJJ| \UUU)
#                        (UU)
#

sudo chsh -s "$(which fish)"

if [ ! -f "$HOME"/.config/fish/functions/fisher.fish ]; then
	curl --proto '=https' --tlsv1.2 -sSf https://git.io/fisher --create-dirs -sLo "$HOME"/.config/fish/functions/fisher.fish
fi

"$(which fish)" -c fisher self-update

cp -f "$HOME"/.asdf/completions/asdf.fish "$HOME"/.config/fish/completions

