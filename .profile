# PATH
export PATH="${HOME}/.krew/bin:${HOME}/.homebrew/bin:${HOME}/.homebrew_x86_64/bin:${HOME}/.homebrew/sbin:${HOME}/.homebrew_x86_64/sbin:${HOME}/bin:/usr/local/bin:/usr/local/sbin:${PATH}"

export HOMEBREW_CASK_OPTS="--appdir=${HOME}/Applications --fontdir=${HOME}/Library/Fonts --no-binaries"
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1

# XDG_CONFIG_DIR
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"

export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
export TERMINAL_MULTIPLEXER=tmux

# You may need to manually set your language environment
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# default editor
export EDITOR='vim'
export VISUAL='vim'

# history
export HISTFILE=~/.bash_history
export HISTSIZE=393216
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL='ignoreboth'
export HISTIGNORE='ls:cd:cd -:pwd:exit:date:* --help:vault*:sshm*'

# pager
export PAGER='less'

# Set the default Less options.
# # Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# # Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# man
export MANPATH="$HOME/.homebrew/share/man${MANPATH+:$MANPATH}:"

# Don't clear the screen after quitting a manual page
export MANPAGER='less -X'

# speed up building ruby
export RUBY_CONFIGURE_OPTS='--disable-install-rdoc --disable-install-ri'

# ruby build cache path
export RUBY_BUILD_CACHE_PATH=~/.rubies/cache

# Allow bundler to use all the cores for parallel installation
export BUNDLE_JOBS=4

# MySQL prompt
export MYSQL_PS1='(\D) \u@\h [\d] > '

# Ensure GREP_OPTIONS is undefined
unset GREP_OPTIONS

# Define grep color
export GREP_COLORS='30;43'

# O ms for key sequences
export KEYTIMEOUT=0

# Bat config
export BAT_CONFIG_PATH="${HOME}/.batrc"

# Setting fd as the default source for fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND='fd --type f --type d --hidden --follow --exclude .git'

export FZF_PREVIEW_COMMAND="bat {} || cat {} || tree -C {}"
export FZF_DEFAULT_OPTS="--history=.fzf_history --history-size=10000
--color fg:15,bg:-1,hl:4,fg+:15,bg+:-1,hl+:4
--color info:7,prompt:3,spinner:4,pointer:4,marker:1
--preview '${FZF_PREVIEW_COMMAND}' --preview-window=right:50%
--bind ctrl-b:preview-page-up,ctrl-f:preview-page-down"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden --bind ?:toggle-preview"
# export FZF_CTRL_T_OPTS="--preview '(${FZF_PREVIEW_COMMAND}) 2> /dev/null | head -${LINES}'"

# lua
export PATH="$HOME/.luarocks/bin:$PATH"

# pyenv
export PYENV_ROOT="${HOME}/.pyenv"
export PATH="${PYENV_ROOT}/bin:${PATH}"

TESSDATA_PREFIX="$(brew --prefix)/share/tessdata"
export TESSDATA_PREFIX

export VALE_STYLES_PATH="${XDG_DATA_HOME}/vale/styles"
