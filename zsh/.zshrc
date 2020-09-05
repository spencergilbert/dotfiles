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

# history search with arrow keys
case `uname` in
	Linux)
		bindkey '^[OA' history-substring-search-up
		bindkey '^[OB' history-substring-search-down
	;;
	Darwin)
		bindkey '^[[A' history-substring-search-up
		bindkey '^[[B' history-substring-search-down
	;;
esac

# history search with arrow keys vim mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# IEx
export ERL_AFLAGS="-kernel shell_history enabled"

# source ASDF
. $HOME/.asdf/asdf.sh
fpath=(${ASDF_DIR}/completions $fpath)

# source skim
[[ -s ~/.skim/shell/key-bindings.zsh ]] && source ~/.skim/shell/key-bindings.zsh

autoload -Uz compinit
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /home/sgilbert/.asdf/installs/consul/1.8.3/bin/consul consul
complete -o nospace -C /home/sgilbert/.asdf/installs/nomad/0.12.3/bin/nomad nomad
complete -o nospace -C /home/sgilbert/.asdf/installs/terraform/0.13.1/bin/terraform terraform
complete -o nospace -C /home/sgilbert/.asdf/installs/vault/1.5.2/bin/vault vault
compinit

eval "$(starship init zsh)"

