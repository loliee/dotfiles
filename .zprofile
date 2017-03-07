# history
export HISTFILE=~/.zsh_history
unsetopt SHARE_HISTORY

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

# O ms for key sequences
export KEYTIMEOUT=0

# Local config
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
