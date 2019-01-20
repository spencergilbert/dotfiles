#
# Executes commands at the start of an interactive session.
#

# use neovim instead of vi/vim
alias vi='nvim'
alias vim='nvim'

### ZSH Options
export HISTFILE=~/.zsh_history  # where to save history
export HISTSIZE=1024            # how many commands from your history are loaded into memory
export SAVEHIST=$HISTSIZE       # how many commands your history file can hold
setopt APPEND_HISTORY 		# append to history file 
setopt SHARE_HISTORY            # imports new commands from the history and appends to file
setopt EXTENDED_HISTORY 	# add additional data to history like timestamp
setopt HIST_IGNORE_ALL_DUPS     # keep no dupes when command is added to history list
setopt HIST_SAVE_NO_DUPS	# when writing to HISTFILE duplicates are omitted
setopt HIST_REDUCE_BLANKS       # trim blanks from command lines
setopt HIST_VERIFY              # show before executing history commands
setopt CORRECT                  # try to correct the spelling of commands
setopt NO_LIST_BEEP
setopt NO_HIST_BEEP
setopt NO_BEEP

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
