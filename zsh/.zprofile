#
# Executes commands at login pre-zshrc.
#

export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# Set the list of directories that Zsh searches for programs.
path=(
  /usr/local/{bin,sbin}
  $HOME/.fzf/bin
  $path
)

# Set golang env vars
export GOPATH=$HOME/Code/Go

# Set path
export PATH="$PATH:$GOPATH/bin:$HOME/.cargo/bin"

# Set the default Less options.
export LESS='-g -i -r'
