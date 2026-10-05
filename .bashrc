# mloliee
# shellcheck shell=bash
# shellcheck disable=SC1090

# Claude Code's Bash tool gets nothing from here
if [[ -n ${CLAUDECODE:-} ]]; then
  return
fi

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

OS=$(uname)

export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# default editor
export EDITOR='nvim'
export VISUAL='nvim'

# XDG_CONFIG_DIR
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"

# pager
export PAGER='less'

# Set the default Less options.
# # Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# # Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# history
export HISTFILE=~/.bash_history
export HISTSIZE=393216
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL='ignoreboth'
export HISTIGNORE='ls:cd:cd -:pwd:exit:date:* --help:vault*:sshm*'

# Define grep color
export GREP_COLORS='30;43'

# O ms for key sequences
export KEYTIMEOUT=0

# Don't clear the screen after quitting a manual page
export MANPAGER='less -X'

# macOS specific
if [[ $OS == "Darwin" ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
  export PATH="${HOME}/.local/share/mise/shims:${HOME}/.krew/bin:${XDG_DATA_HOME}/../bin:/opt/homebrew/bin:${HOME}/.homebrew_x86_64/bin:/opt/homebrew/sbin:${HOME}/.homebrew_x86_64/sbin:${HOME}/bin:/usr/local/bin:/usr/local/sbin:${PATH}"
  export HOMEBREW_CASK_OPTS="--appdir=${HOME}/Applications --fontdir=${HOME}/Library/Fonts --require-sha"
  export HOMEBREW_NO_ANALYTICS=1
  export HOMEBREW_NO_INSECURE_REDIRECT=1
  export HOMEBREW_VERIFY_ATTESTATIONS=1
  export HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK=1
  export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
fi

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
