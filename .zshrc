# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Fix history arrow binding on tmux
bindkey '^[[B' history-substring-search-down
bindkey '^[[A' history-substring-search-up

# Aliases
[[ -f ~/.aliases ]] && source ~/.aliases
