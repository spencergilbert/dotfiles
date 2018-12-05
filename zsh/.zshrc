#
# Executes commands at the start of an interactive session.
#

# Source Antibody
if [[ -s ~/.zsh_plugins.sh ]]; then
  source ~/.zsh_plugins.sh
fi

# Use neovim instead of vi/vim
alias vi='nvim'
alias vim='nvim'

### Extra ZSH options ###
# If querying the user before executing `rm *' or `rm
# path/*', first wait ten seconds and ignore anything typed
# in that time. This avoids the problem of reflexively
# answering `yes' to the query when one didn't really mean
# it.
setopt RM_STAR_WAIT

# Speed up zsh compinit by only checking cache once a day
autoload -Uz compinit
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
  compinit -i
else
  compinit -C -i
fi