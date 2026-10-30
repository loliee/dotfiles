# PATH
set -x PATH $HOME/.local/share/mise/shims $HOME/.krew/bin $HOME/.local/bin /opt/homebrew/bin $HOME/.homebrew_x86_64/bin /opt/homebrew/sbin $HOME/.homebrew_x86_64/sbin $HOME/bin /usr/local/bin /usr/local/sbin $PATH

set -x HOMEBREW_CASK_OPTS "--appdir=$HOME/Applications --fontdir=$HOME/Library/Fonts --require-sha"
set -x HOMEBREW_NO_ANALYTICS 1
set -x HOMEBREW_NO_INSECURE_REDIRECT 1
set -x HOMEBREW_VERIFY_ATTESTATIONS 1
set -x HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK 1

# Copilot CLI updates itself past the version mise pins; only this variable stops it (github/copilot-cli#4534)
set -x COPILOT_AUTO_UPDATE false

# macOS starts shells at 256 open files: parallel installs (mise, aube) and language servers run out
test (ulimit -S -n) -lt 10240 2>/dev/null; and ulimit -S -n 10240

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
set -x MANPATH "/opt/homebrew/share/man"(test -n "$MANPATH"; and echo :$MANPATH; or echo :)

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
# Last: rustup's cargo and rustc must not shadow the Rust that mise pins
set -x PATH $PATH $HOME/.cargo/bin

# go
if type -q go
    fish_add_path (go env GOPATH)/bin
end

if type -q colima
    set -x COLIMA_SAVE_CONFIG 0
end

if type -q dyff
    set -x KUBECTL_EXTERNAL_DIFF "dyff between --omit-header --set-exit-code"
end

# lua
set -x PATH $HOME/.luarocks/bin $PATH

# Lua
if type -q luarocks; and test -z "$LUA_PATH"
    set -Ux LUA_PATH (luarocks path --lr-path)
    set -Ux LUA_CPATH (luarocks path --lr-cpath)
end

if type -q ollama
    set -x OLLAMA_CONTEXT_LENGTH 32768
end

# rclone.conf has no global section: shared settings go through environment variables.
#   RCLONE_<FLAG>            global option              (--transfers → RCLONE_TRANSFERS)
#   RCLONE_<BACKEND>_<OPT>   every remote of that type  (--s3-chunk-size → RCLONE_S3_CHUNK_SIZE)
# Precedence: command-line flag > remote option in rclone.conf > these variables.
#
# Peak memory ≈ transfers × (buffer_size + s3_chunk_size × s3_upload_concurrency)
#             ≈ 8 × (32M + 16M × 4) ≈ 768 MB. Lower transfers on small machines.

# ── Parallelism ───────────────────────────────────────────────────────
set -x RCLONE_TRANSFERS 8 # default 4: files transferred in parallel
set -x RCLONE_CHECKERS 16 # default 8: parallel comparisons
set -x RCLONE_BUFFER_SIZE 32M # default 16M: in-memory buffer per file
set -x RCLONE_MULTI_THREAD_STREAMS 8 # default 4: parallel chunks for large files

# ── Listing ───────────────────────────────────────────────────────────
# One recursive request instead of one per directory: much faster and cheaper
# on S3/R2/B2. Ignored by backends that don't support it.
# Cost: the whole listing is held in memory (an issue past a few million objects).
set -x RCLONE_FAST_LIST true

# ── Resilience ────────────────────────────────────────────────────────
set -x RCLONE_RETRIES 5 # default 3: retries of the whole operation
set -x RCLONE_RETRIES_SLEEP 10s # default 0: pause between retries
set -x RCLONE_USE_MMAP true # returns memory to the OS sooner

# ── Output ────────────────────────────────────────────────────────────
set -x RCLONE_STATS_ONE_LINE true # compact stats (with -P or --stats)

# ── Shared filters (macOS/Windows system files) ───────────────────────
set -x RCLONE_EXCLUDE_FROM $HOME/.config/rclone/exclude.txt

# ── Backends ──────────────────────────────────────────────────────────
# S3 and compatibles (AWS, R2, Wasabi, MinIO…)
set -x RCLONE_S3_CHUNK_SIZE 16M # default 5M: fewer requests per large file

# SFTP: larger packets, accepted by OpenSSH
# (revert to 32k if an unusual server returns errors)
set -x RCLONE_SFTP_CHUNK_SIZE 255k # default 32k

# ── Mounts (rclone mount / serve), no effect on copy/sync ─────────────
set -x RCLONE_VFS_CACHE_MODE writes # required by many apps that write files
set -x RCLONE_VFS_CACHE_MAX_SIZE 10G
set -x RCLONE_VFS_CACHE_MAX_AGE 24h
set -x RCLONE_DIR_CACHE_TIME 5m

if test -f ~/.env.local.fish
    source ~/.env.local.fish
end
