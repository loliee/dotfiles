# Fetch 1password secrets

if ! status --is-login
    exit 0
end

if test $TERM != screen && test -z "$TMUX"
    exit 0
end

ensure-cmd tmux op yq; or exit 1
opx-fetch; or exit 1
