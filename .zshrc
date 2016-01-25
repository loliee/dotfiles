# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Use vi-mode in Your Shell, see also vi-mode plugin
bindkey -M viins ',,' vi-cmd-mode
bindkey -M viins ';;' vi-cmd-mode

# Aliases
[[ -f ~/.aliases ]] && source ~/.aliases
