# Tmux

if test $TERMINAL_MULTIPLEXER = tmux
    if ! tmux has-session -t=ml &>/dev/null
        TMUX='' tmux new-session -d -s ml
    end

    if test -z "$TMUX"
        tmux attach -t ml
    else
        tmux switch-client -t ml
    end
end