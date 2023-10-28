# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Completion must ignore /etc/hosts entries
# this has no effect when defined in ~/.zpreztorc
zstyle ':completion:*:hosts' hosts 'off'

# Fix history arrow binding on tmux
bindkey '^[[B' history-substring-search-down
bindkey '^[[A' history-substring-search-up

# Starship
eval "$(starship init zsh)"

# Minio competion
command -v mc &>/dev/null && {
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C "${HOMEBREW_ROOT}/bin/mc" mc
}

# Aliases
[[ -f ${HOME}/.aliases ]] && source ${HOME}/.aliases

# Local config
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
