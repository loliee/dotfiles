#!/usr/bin/env bash
# Aliases
# vim: syntax=sh

OS="${OS:-$(uname)}"

if command -v nvim &>/dev/null; then
  alias vi='nvim'
  alias vim='nvim'
fi

alias sshz='ssh -F /dev/null -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"'

command -v cargo &>/dev/null && alias ca='cargo'
command -v direnv &>/dev/null && alias da='direnv allow'
command -v diskonaut &>/dev/null && alias ncdu='diskonaut'

# docker-compose
command -v docker-compose &>/dev/null && alias dc='docker-compose'

# kubernetes
command -v k &>/dev/null && alias k='k9s'
command -v kubectl &>/dev/null && alias kb='kubectl'
command -v kubectx &>/dev/null && alias kx='kubectx'
command -v kubens &>/dev/null && alias kn='kubens'

command -v rg &>/dev/null && alias rga='rg --hidden --no-ignore' && alias rgd='rg --hidden'

# AWS S3
command -v aws &>/dev/null && alias aws3="aws s3api"

colors() {
  for code in $(seq -w 0 255); do for attr in 0 1; do
    printf '%s-%03s %b■■■■%b\n' "${attr}" "${code}" "\\e[${attr};38;05;${code}m" '\e[m'
  done; done | column -c $((COLUMNS * 2))
}

# Automatically Starting tmux on SSH
ssht() {
  for SSH_HOST; do true; done
  tabname "$SSH_HOST"
  ssh "$@" -t 'tmux ls && exec tmux a || exec tmux new || exec $SHELL -l'
}

# FZF amazing fuzzy finder
if command -v fzf &>/dev/null; then
  # fkill - kill process
  fkill() {
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [ "x$pid" != "x" ]; then
      kill -"${1:-9}" "$pid"
    fi
  }

  # git checkout
  gco() {
    local branches branch
    branches=$(git --no-pager branch -vv) &&
      branch=$(echo "${branches}" | FZF_DEFAULT_OPTS="" fzf +m) &&
      git checkout "$(echo "$branch" | awk '{print $1}' | sed "s/.* //")"
  }

  gcoo() {
    local branches branch
    branches=$(git for-each-ref --count=60 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
      branch=$(echo "${branches}" |
        FZF_DEFAULT_OPTS="" fzf -d $((2 + $(wc -l <<<"${branches}"))) +m) &&
      git checkout "$(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
  }
fi

if [[ ${OS} == 'Linux' ]]; then
  # can i haz color
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias la='ls -A'
  alias l='ls -lAh'

  # Find large files and directories
  alias fat='du -a | sort -n -r | head -n 20'

  # Show open ports
  alias ports='netstat -tulanp'

  # Memory
  alias meminfo='free -m -l -t'

  # Get top process eating memory
  alias psmem='ps auxf | sort -nr -k 4'
  alias psmem10='ps auxf | sort -nr -k 4 | head -10'

  # Get top process eating cpu
  alias pscpu='ps auxf | sort -nr -k 3'
  alias pscpu10='ps auxf | sort -nr -k 3 | head -10'

  # Count all opened files by all process
  alias count_opened_files='lsof | wc -l'

  # Get maximum open files count allowed
  alias max_open_files='cat /proc/sys/fs/file-max'

  # Flush swap
  alias swapoffon='nohup bash -c "swapoff -a; swapon -a" &>/dev/null'

  # Yolo
  alias dropcache='sync && echo 3 > /proc/sys/vm/drop_caches'

  alias tf='sudo tail -f'
fi
