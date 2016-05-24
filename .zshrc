# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Fix history arrow binding on tmux
bindkey '^[[B' history-substring-search-down
bindkey '^[[A' history-substring-search-up

# Aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# The next line updates PATH for the Google Cloud SDK.
source '/Users/mloliee/Downloads/google-cloud-sdk/path.zsh.inc'

# The next line enables shell command completion for gcloud.
source '/Users/mloliee/Downloads/google-cloud-sdk/completion.zsh.inc'
