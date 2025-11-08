# mloliee
# shellcheck shell=bash
# shellcheck disable=SC1090

# vi mode
set -o vi

# append history instead of rewriting it
shopt -s histappend

# save multi-line commands in history as single line
shopt -s cmdhist

# autocorrects cd misspellings
shopt -s cdspell

# include dotfiles in pathname expansio
shopt -s dotglob

# expand aliases
shopt -s expand_aliases

# enable extended pattern-matching features
shopt -s extglob

# pathname expansion will be treated as case-insensitive
shopt -s nocaseglob

# Prompt
if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
elif [[ -f "${HOME}/.patatetoy/patatetoy.sh" ]]; then
  # shellcheck source=/dev/null
  source "${HOME}/.patatetoy/patatetoy.sh"
fi

# bash completions
if [[ -r /etc/bash_completion ]]; then
  # shellcheck disable=SC1091
  source /etc/bash_completion
fi

if [[ -r /etc/profile.d/bash_completion.sh ]]; then
  # shellcheck disable=SC1091
  source /etc/profile.d/bash_completion.sh
fi

# https://docs.brew.sh/Shell-Completion
if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
  export BASH_COMPLETION_COMPAT_DIR="${HOMEBREW_PREFIX}/etc/bash_completion.d"
  # shellcheck disable=SC1091
  source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
else
  for completion in "${HOMEBREW_PREFIX}"/etc/bash_completion.d/*; do
    [[ -r $completion ]] && source "$completion"
  done
fi

# Save bash history after each command, depend `shopt -s histappend`
PROMPT_COMMAND="history -a;history -c;history -r;$PROMPT_COMMAND"

# chruby
if [[ -f "${HOMEBREW_PREFIX}/share/chruby/chruby.sh" ]]; then
  # shellcheck disable=SC2034
  RUBIES=("${HOME}/.rubies/*")

  # shellcheck source=/dev/null
  source "${HOMEBREW_PREFIX}/share/chruby/chruby.sh"
  # shellcheck source=/dev/null
  source "${HOMEBREW_PREFIX}/share/chruby/auto.sh"
fi

# fvm node manager
if command -v fnm &>/dev/null; then
  eval "$(fnm env --use-on-cd)"
fi

# Pyenv
if command -v pyenv &>/dev/null; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash --cmd j)"
fi

if command -v direnv &>/dev/null; then
  eval "$(direnv hook bash)"
fi

# Auto attach|start ssh-agent
# SSH_AGENT=${SSH_AGENT:-"${HOME}/.ssh-agent"}
#
# if [[ -r $SSH_AGENT ]]; then
#   eval "$(<"$SSH_AGENT")" >/dev/null
# fi
#
# if [[ -z ${SSH_AGENT_PID} ]] || ! kill -0 "${SSH_AGENT_PID}" &>/dev/null; then
#   (
#     umask 066
#     ssh-agent >"${SSH_AGENT}"
#   )
#
#   eval "$(<"$SSH_AGENT")" >/dev/null
# fi

# if ! ssh-add -l &>/dev/null; then
#   trap '' SIGINT
#   ssh-add -t 8h
#   trap - SIGINT
# fi

# Load other files
_FILES=(
  ".aliases"
  ".aliases.bash"
  ".aliases.local"
  ".bashrc.remote"
  ".env.local"
  ".fzf.bash"
)

for f in "${_FILES[@]}"; do
  # shellcheck source=/dev/null
  [[ -f $f ]] && source "${HOME}/$f"
done
