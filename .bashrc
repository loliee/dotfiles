# ~/.bashrc

SHELL=$(command -v bash)

shopt -s cdable_vars        # if cd arg is not valid, assumes its a var defining a dir
shopt -s cdspell            # autocorrects cd misspellings
shopt -s checkwinsize       # update the value of LINES and COLUMNS after each command if altered
shopt -s cmdhist            # save multi-line commands in history as single line
shopt -s dotglob            # include dotfiles in pathname expansion
shopt -s expand_aliases     # expand aliases
shopt -s extglob            # enable extended pattern-matching features
shopt -s hostcomplete       # attempt hostname expansion when @ is at the beginning of a word
shopt -s nocaseglob         # pathname expansion will be treated as case-insensitive

# Setup vi mode
set -o vi

# Locale
export LANGUAGE="en_US.UTF-8"

# Editor
export VISUAL=vim
export EDITOR="${VISUAL}"

# History
export HISTFILESIZE=10000
export HISTCONTROL=ignorespace
export HISTFILE=~/.bash_history
shopt -s histverify
shopt -s histappend

# Specific linux takeaway aliases
alias grep='grep --color'

# shellcheck source=/dev/null
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# Force docker completion file loading
# shellcheck source=/dev/null
if [ -f /usr/share/bash-completion/completions/docker ]; then
  . /usr/share/bash-completion/completions/docker
fi

# shellcheck source=/dev/null
if [ -f "${TMUXDIR}/.patatetoy/patatetoy.sh" ]; then
    export PATATETOY_INSTALL_DIR=$TMUXDIR
  . "${TMUXDIR}/.patatetoy/patatetoy.sh"
elif [ -f "${HOME}/.patatetoy/patatetoy.sh" ]; then
  . "${HOME}/.patatetoy/patatetoy.sh"
fi

# shellcheck source=/dev/null
if [ -f /usr/local/share/chruby/chruby.sh ]; then
  . /usr/local/share/chruby/chruby.sh
fi

# shellcheck source=/dev/null
if [ -f "${HOME}/.aliases" ]; then
  . "${HOME}/.aliases"
fi

export PATH=/opt/bin:$PATH
