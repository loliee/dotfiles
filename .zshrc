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

# Gcloud SDK
GOOGLE_SDK_PATH="${ZDOTDIR:-$HOME}/.homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
if [[ -f "${GOOGLE_SDK_PATH}/path.zsh.inc" && -f "${GOOGLE_SDK_PATH}/completion.zsh.inc" ]]; then
  source "${GOOGLE_SDK_PATH}/path.zsh.inc"
  source "${GOOGLE_SDK_PATH}/completion.zsh.inc"
fi

# Aliases
[[ -f ${HOME}/.aliases ]] && source ${HOME}/.aliases
