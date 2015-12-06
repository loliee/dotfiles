# PATH
export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH

# You may need to manually set your language environment
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# default editor
export EDITOR='vim'
export VISUAL='vim'

# history
export HISTFILE=~/.zsh_history
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL='ignoreboth'
export HISTIGNORE='ls:cd:cd -:pwd:exit:date:* --help'
unsetopt SHARE_HISTORY

# Enable persistent REPL history for `node`.
export NODE_REPL_HISTORY_FILE=~/.node_history;
# Allow 32³ entries; the default is 1000.
export NODE_REPL_HISTORY_SIZE='32768';

# pager
export PAGER='less'
export LESS='-r -R --follow-name'

# Don't clear the screen after quitting a manual page
export MANPAGER='less -X'

# color scheme
# export TERM='patatetoy'
# BASE16_SHELL=~/.base16-shell/base16-tomorrow.dark.sh
[[ -f $BASE16_SHELL ]] && source $BASE16_SHELL

# enable cheat syntax highlighting
# export CHEATCOLORS=true

# speed up building ruby
export RUBY_CONFIGURE_OPTS='--disable-install-rdoc --disable-install-ri'

# ruby build cache path
export RUBY_BUILD_CACHE_PATH=~/.rubies/cache

# Allow bundler to use all the cores for parallel installation
export BUNDLE_JOBS=4

# MySQL prompt
export MYSQL_PS1='(\D) \u@\h [\d] > '

# Link Homebrew casks in `/Applications` rather than `~/Applications`
export HOMEBREW_CASK_OPTS='--appdir=/Applications'

# Always enable colored `grep` output
export GREP_OPTIONS='--color=auto'

# 10ms for key sequences
export KEYTIMEOUT=1

# homebrew
export HOMEBREW_ROOT='/usr/local'

# Local config
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

# Setting ag as the default source for fzf
export FZF_DEFAULT_COMMAND='ag -l -g ""'