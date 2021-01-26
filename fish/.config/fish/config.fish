# sk + fd + bat
set -x SKIM_DEFAULT_COMMAND 'fd --type file --follow --hidden --exclude .git --color=always'
set -x SKIM_DEFAULT_OPTS '--ansi'

set -x SKIM_CTRL_T_COMMAND "$SKIM_DEFAULT_COMMAND"
set -x SKIM_CTRL_T_OPTS "$SKIM_DEFAULT_OPTS --preview-window right:60% --preview 'bat --color=always --style=header,grid --line-range :300 {}'"

set -x SKIM_ALT_C_COMMAND 'fd -L --type directory -E /sys -E /proc -E /dev -E /tmp'

set -x BAT_THEME 'Dracula'

# Go
set -x GOPATH $HOME/Code/Go
set -x PATH $PATH $GOPATH/bin

# Neovim
abbr vim 'nvim'

# Environment Variables
set EDITOR nvim
set VISUAL nvim
set fish_greeting

source ~/.asdf/asdf.fish
# source ~/.cargo/env

zoxide init fish | source
starship init fish | source
