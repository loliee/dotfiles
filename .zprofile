# PATH
export PATH="${HOME}/.homebrew/bin:${HOME}/.homebrew/opt/openssl@1.1/bin:${HOME}/.homebrew/sbin:${PATH}"

# You may need to manually set your language environment
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# default editor
export EDITOR='vim'
export VISUAL='vim'

# history
export HISTFILE=~/.zsh_history
export HISTSIZE=393216
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL='ignoreboth'
export HISTIGNORE='ls:cd:cd -:pwd:exit:date:* --help:vault*'
unsetopt SHARE_HISTORY

# travis
[[ -f "${HOME}/.travis/travis.sh" ]] \
  && source "${HOME}/.travis/travis.sh"

# Enable persistent REPL history for `node`.
export NODE_REPL_HISTORY_FILE=~/.node_history;
# Allow 32³ entries; the default is 1000.
export NODE_REPL_HISTORY_SIZE='32768';

# pager
export PAGER='less'

# Set the default Less options.
# # Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# # Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

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
export GREP_COLOR='30;43'

# O ms for key sequences
export KEYTIMEOUT=0

# homebrew
export HOMEBREW_ROOT=$(brew --prefix)
export HOMEBREW_CASK_OPTS="--appdir=${HOME}/Applications --fontdir=/Library/Fonts --no-binaries"

# fvm
eval "$(fnm env)"

# Bat config
export BAT_CONFIG_PATH="${HOME}/.batrc"

# Setting fd as the default source for fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND='fd --type f --type d --hidden --follow --exclude .git'

# fzf preview
export FZF_PREVIEW_COMMAND="bat {} || cat {} || tree -C {}"
export FZF_DEFAULT_OPTS="--history=.fzf_history --history-size=10000
--color fg:15,bg:-1,hl:4,fg+:15,bg+:-1,hl+:4
--color info:7,prompt:3,spinner:4,pointer:4,marker:1
--preview '($FZF_PREVIEW_COMMAND) 2> /dev/null' --preview-window=right:50%
--bind ctrl-b:preview-page-up,ctrl-f:preview-page-down"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden --bind ?:toggle-preview"
export FZF_CTRL_T_OPTS="--preview '($FZF_PREVIEW_COMMAND) 2> /dev/null | head -$LINES'"
#
# Switch pure prompt theme to vi mode
export PATATETOY_VIM_MODE=1

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

# direnv
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# chruby
if [[ -f "$(brew --prefix)/share/chruby/chruby.sh" ]]; then
  RUBIES=(~/.rubies/*)
  source "$(brew --prefix)/share/chruby/chruby.sh"
  source "$(brew --prefix)/share/chruby/auto.sh"

  [[ -f ~/.ruby-version ]] && chruby "$(cat ~/.ruby-version)"
fi

export GROOVY_HOME=/usr/local/opt/groovy/libexec

# Rust
if [[ -d "${HOME}/.cargo/bin" ]]; then
  export PATH="${HOME}/.cargo/bin:${PATH}"
  source $HOME/.cargo/env
fi

# K9S
export K9SCONFIG="${HOME}/.config/k9s"
