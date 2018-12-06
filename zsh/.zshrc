#
# Executes commands at the start of an interactive session.
#

# use neovim instead of vi/vim
alias vi='nvim'
alias vim='nvim'

### ZSH Options

setopt NO_LIST_BEEP             # no beep on an ambiguous completion
HISTSIZE=1024                   # how many commands from your history are loaded into memory
HISTFILESIZE=1024               # how many commands your history file can hold
HISTFILE=~/.zsh_history         # where to save history
setopt HIST_IGNORE_ALL_DUPS     # when command is added to history remove older dup
setopt HIST_FIND_NO_DUPS        # do not display duplicates of a line previously found
setopt HIST_REDUCE_BLANKS       # trim blanks from command lines
setopt SHARE_HISTORY            # imports new commands from the history and appends to file
setopt HIST_VERIFY              # show before executing history commands
setopt CORRECT                  # try to correct the spelling of commands
setopt NO_BEEP                  #

# engaging Vi mode
bindkey -v

export KEYTIMEOUT=1

# source Antibody
[[ -s ~/.zsh_plugins.sh ]] && source ~/.zsh_plugins.sh

# speed up zsh compinit by only checking cache once a day
autoload -Uz compinit
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
  compinit -i
else
  compinit -C -i
fi

# source asdf
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
