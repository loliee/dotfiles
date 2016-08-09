# ~/.bashrc

SHELL=$(which bash)

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

# Setup history
export HISTSIZE=10000
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

# shellcheck source=/dev/null
if [ -f ~/.patatetoy/patatetoy.sh ]; then
  . ~/.patatetoy/patatetoy.sh
fi

# shellcheck source=/dev/null
if [ -f ~/.aliases ]; then
  . ~/.aliases
fi

export PATH=/opt/bin:$PATH
