# Expand path
export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH

# You may need to manually set your language environment
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Allow bundler to use all the cores for parallel installation
export BUNDLE_JOBS=4

# default editor
export EDITOR='vim'
export VISUAL='vim'

# History
export HISTSIZE=32768
export HISTCONTROL=ignoreboth
export HISTFILESIZE=$HISTSIZE
export HISTIGNORE='ls:cd:cd -:pwd:exit:date:* --help'

# pager
export PAGER='less'

# Don't clear the screen after quitting a manual page
export MANPAGER='less -X'

# MySQL prompt
export MYSQL_PS1='(\D) \u@\h [\d] > '

# Set the default Less options.
# # Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# # Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Enable persistent REPL history for `node`.
export NODE_REPL_HISTORY_FILE=~/.node_history;
# Allow 32³ entries; the default is 1000.
export NODE_REPL_HISTORY_SIZE='32768';

# homebrew
# shellcheck disable=SC2039
hash brew &>/dev/null \
  && export HOMEBREW_ROOT='/usr/local' \
  && export HOMEBREW_CASK_OPTS='--appdir=/Applications  --caskroom=/usr/local/Caskroom'

# Nvm
export NVM_DIR="$HOME/.nvm"

# Switch pure prompt theme to vi mode
export PATATETOY_VIM_MODE=1

# speed up building ruby
export RUBY_CONFIGURE_OPTS='--disable-install-rdoc --disable-install-ri'

# ruby build cache path
export RUBY_BUILD_CACHE_PATH=~/.rubies/cache

# FZF config
# shellcheck disable=SC2039
if [[ "$(hash fzf &>/dev/null; echo $?)" == '0' ]]; then
  export FZF_DEFAULT_OPTS='--history=.fzf_history --history-size=10000
    --color fg:15,bg:-1,hl:4,fg+:15,bg+:-1,hl+:4
    --color info:7,prompt:3,spinner:4,pointer:4,marker:1'
  hash ag &>/dev/null \
    && export FZF_DEFAULT_COMMAND='ag -l -g ""' \
    && export FZF_ALLFILES_COMMAND='ag -l -a --hidden'
  hash ack &>/dev/null \
    && export FZF_DEFAULT_COMMAND='ack -l  ""' \
    && export FZF_ALLFILES_COMMAND=$FZF_DEFAULT_COMMAND
fi

# travis
# shellcheck source=/dev/null disable=SC2039
[[ -f "/usr/local/share/zsh/site-functions/_travis" ]] \
  && source "/usr/local/share/zsh/site-functions/_travis"

# chruby
# shellcheck source=/dev/null disable=SC2039
if [[ -f '/usr/local/share/chruby/chruby.sh' ]]; then
  export RUBIES=(~/.rubies/*)
  source '/usr/local/share/chruby/chruby.sh'
  source '/usr/local/share/chruby/auto.sh'
  [[ -f ~/.ruby-version ]] && chruby "$(cat ~/.ruby-version)"
fi

# Magic per-project shell environments. Very pretentious.
# shellcheck source=/dev/null disable=SC2039
[[ -f "${HOMEBREW_ROOT}/opt/autoenv/activate.sh" ]] && \
  source "${HOMEBREW_ROOT}/opt/autoenv/activate.sh"
