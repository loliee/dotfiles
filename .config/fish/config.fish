status is-interactive; or exit 0

# No welcome msg
set fish_greeting

# Cursor shape
set fish_cursor_default block
set fish_cursor_insert block
set fish_cursor_external line

# Load local functions
if test -d $XDG_CONFIG_HOME/fish/functions_local
    set fish_function_path $fish_function_path $XDG_CONFIG_HOME/fish/functions_local
end

# -----------------------------------------------------------------------------------------------------------------
# Hooks
# -----------------------------------------------------------------------------------------------------------------

direnv hook fish | source
fnm env --use-on-cd | source
starship init fish | source
zoxide init fish --cmd j | source

# -----------------------------------------------------------------------------------------------------------------
# Abbreviations
# cf. https://fishshell.com/docs/current/cmds/abbr.html
# -----------------------------------------------------------------------------------------------------------------
abbr --add rms shred --remove

abbr --add G --position anywhere --set-cursor "| rg %"
abbr --add L --position anywhere --set-cursor "% | less"

command -q aws &>/dev/null; and abbr --add aws3 aws s3api
command -q direnv &>/dev/null; and abbr --add da direnv allow

command -q rg &>/dev/null; and abbr --add rga rg --hidden --no-ignore

# Docker
command -q docker &>/dev/null; and abbr --add d docker
command -q docker-compose &>/dev/null; and abbr --add dc docker compose

# Kubernerntes
command -q k9s &>/dev/null; and abbr --add k k9s
command -q kubectl &>/dev/null; and abbr --add kb kubectl
command -q kubens &>/dev/null; and abbr --add kn kubens
command -q kubectx &>/dev/null; and abbr --add kx kubectx

# Git absorb
if command -q git-absorb &>/dev/null
    abbr --add ga git absorb
    abbr --add gaf git absorb --force
    abbr --add gar git absorb --and-rebase
    abbr --add garf git absorb --and-rebase
end

if command -q uv &>/dev/null
    abbr --add pip uv pip
end

abbr fe --set-cursor=! "find . -name '*' -exec ! '{}' \;"
abbr fed --set-cursor=! "find . -name '*' -type d -exec ! '{}' \;"

abbr --add sshz ssh -F /dev/null -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"
abbr --add rma 'ls ~/.ssh/* | rg $USER@ | xargs -I % rm -f %'

abbr --add dns-flushcache "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
