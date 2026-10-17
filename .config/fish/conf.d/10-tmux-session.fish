# Tmux

if ! status --is-login; or ! status --is-interactive; or ! isatty stdin
    exit 0
end

# never from Claude Code / Cowork shells
if set -q CLAUDECODE; or test "$TERM_PROGRAM" != ghostty
    exit 0
end

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
