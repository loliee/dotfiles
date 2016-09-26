# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Fix history arrow binding on tmux
bindkey '^[[B' history-substring-search-down
bindkey '^[[A' history-substring-search-up

# Aliases
[[ -f ${HOME}/.aliases ]] && source ${HOME}/.aliases

# Completions
GCLOUD_SDK=/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk
[[ -f "$GCLOUD_SDK/path.zsh.inc" ]] && source "${GCLOUD_SDK}/path.zsh.inc"
[[ -f "${GCLOUD_SDK}/completion.zsh.inc" ]] && source "${GCLOUD_SDK}/completion.zsh.inc"
[[ -f "${HOME}/.travis/travis.sh" ]] && source "${HOME}/.travis/travis.sh"
[[ -f "$HOME/.kubectl.completion.zsh" ]] && source "$HOME/.kubectl.completion.zsh" && compdef kb=kubectl

compdef sshrc=ssh
compdef ssht=ssh
hash docker-compose &>/dev/null && compdef dc=docker-compose
