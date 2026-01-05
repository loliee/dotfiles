# -----------------------------------------------------------------------------------------------------------------
# Abbreviations
# cf. https://fishshell.com/docs/current/cmds/abbr.html
# -----------------------------------------------------------------------------------------------------------------
status is-interactive; or exit 0

abbr --add rms shred --remove

abbr --add G --position anywhere --set-cursor "| rg %"
abbr --add L --position anywhere --set-cursor "% | less"

command -q aws; and abbr --add aws3 aws s3api
command -q direnv; and abbr --add da direnv allow

command -q rg; and abbr --add rga rg --hidden --no-ignore

# Docker
command -q docker; and abbr --add d docker
command -q docker compose; and abbr --add dc docker compose

# Kubernerntes
command -q k9s; and abbr --add k k9s
command -q kubectl; and abbr --add kb kubectl
command -q kubens; and abbr --add kn kubens
command -q kubectx; and abbr --add kx kubectx

# Git absorb
if command -q git-absorb
    abbr --add ga git absorb
    abbr --add gaf git absorb --force
    abbr --add gar git absorb --and-rebase
    abbr --add garf git absorb --and-rebase
end

command -q uv; and abbr --add pip uv pip

abbr fe --set-cursor=! "find . -name '*' -exec ! '{}' \;"
abbr fed --set-cursor=! "find . -name '*' -type d -exec ! '{}' \;"

abbr --add sshz ssh -F /dev/null -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"
abbr --add rma 'ls ~/.ssh/* | rg $USER@ | xargs -I % rm -f %'

abbr --add dns-flushcache "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
