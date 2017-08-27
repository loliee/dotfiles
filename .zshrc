# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Fix history arrow binding on tmux
bindkey '^[[B' history-substring-search-down
bindkey '^[[A' history-substring-search-up

# google completion
hash kubectl &>/dev/null && source <(kubectl completion zsh)
hash gcloud &>/dev/null && \
  source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
#
# Aliases
[[ -f ${HOME}/.aliases ]] && source ${HOME}/.aliases
