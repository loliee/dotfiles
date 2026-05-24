# PATH
set -x PATH $HOME/.krew/bin $XDG_DATA_HOME/../bin $HOME/.homebrew/bin $HOME/.homebrew_x86_64/bin $HOME/.homebrew/sbin $HOME/.homebrew_x86_64/sbin $HOME/bin /usr/local/bin /usr/local/sbin $PATH

set -x HOMEBREW_CASK_OPTS "--appdir=$HOME/Applications --fontdir=$HOME/Library/Fonts --no-binaries"
set -x HOMEBREW_NO_ANALYTICS 1
set -x HOMEBREW_NO_INSECURE_REDIRECT 1
set -x HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK 1

# XDG_CONFIG_DIR
set -x XDG_CONFIG_HOME (set -q XDG_CONFIG_HOME; and echo $XDG_CONFIG_HOME; or echo $HOME/.config)
set -x XDG_DATA_HOME (set -q XDG_DATA_HOME; and echo $XDG_DATA_HOME; or echo $HOME/.local/share)

set -x SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
set -x TERMINAL_MULTIPLEXER tmux

# Locale
test -z "$LANG"; and set -x LANG 'en_US.UTF-8'
test -z "$LC_ALL"; and set -x LC_ALL 'en_US.UTF-8'

# default editor
set -x EDITOR nvim
set -x VISUAL nvim

# Colorize my fish functions
set -x CLICOLOR 1

# pager
set -x PAGER less

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
set -x LESS '-F -g -i -M -R -S -w -X -z-4'

# man
set -x MANPATH "$HOME/.homebrew/share/man"(test -n "$MANPATH"; and echo :$MANPATH; or echo :)

# Don't clear the screen after quitting a manual page
set -x MANPAGER 'less -X'

# speed up building ruby
set -x RUBY_CONFIGURE_OPTS '--disable-install-rdoc --disable-install-ri'

# ruby build cache path
set -x RUBY_BUILD_CACHE_PATH $HOME/.rubies/cache

# Allow bundler to use all the cores for parallel installation
set -x BUNDLE_JOBS 4

set -x SSHRC_USER loliee

# MySQL prompt
set -x MYSQL_PS1 '(\D) \u@\h [\d] > '

# Ensure GREP_OPTIONS is undefined
set -e GREP_OPTIONS

# Define grep color
set -x GREP_COLORS '30;43'

# O ms for key sequences
set -x KEYTIMEOUT 0

# Bat config
set -x BAT_CONFIG_PATH "$HOME/.batrc"

# Setting fd as the default source for fzf
set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -x FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
set -x FZF_CTRL_T_COMMAND 'fd --type f --type d --hidden --follow --exclude .git'

set -x FZF_PREVIEW_COMMAND "bat {} || cat {} || tree -C {}"
set -x FZF_DEFAULT_OPTS "--history=.fzf_history --history-size=10000
--color fg:15,bg:-1,hl:4,fg+:15,bg+:-1,hl+:4
--color info:7,prompt:3,spinner:4,pointer:4,marker:1
--preview '$FZF_PREVIEW_COMMAND' --preview-window=right:50%
--bind ctrl-b:preview-page-up,ctrl-f:preview-page-down"
set -x FZF_CTRL_T_OPTS "--preview '($FZF_PREVIEW_COMMAND) 2> /dev/null | head -$LINES'"

# cargo
set -x PATH $HOME/.cargo/bin $PATH

set -x TESSDATA_PREFIX $HOME/.homebrew/share/tessdata

# lua
set -x PATH $HOME/.luarocks/bin $PATH

# Lua
if type -q luarocks; and test -z "$LUA_PATH"
    set -Ux LUA_PATH (luarocks path --lr-path)
    set -Ux LUA_CPATH (luarocks path --lr-cpath)
end

if test -f ~/.env.local.fish
    source ~/.env.local.fish
end
