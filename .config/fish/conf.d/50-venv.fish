# https://gist.github.com/tommyip/cf9099fa6053e30247e5d0318de2fb9e
function __auto_source_venv --on-variable PWD --description "Activate/Deactivate virtualenv on directory change"
    status --is-command-substitution; and return

    # Check if we are inside a git directory
    if git rev-parse --show-toplevel &>/dev/null
        set gitdir (realpath (git rev-parse --show-toplevel))
        set cwd (pwd -P)
        # While we are still inside the git directory, find the closest
        # virtualenv starting from the current directory.
        while string match "$gitdir*" "$cwd" &>/dev/null
            if test -e "$cwd/.venv/bin/activate.fish"
                source "$cwd/.venv/bin/activate.fish" &>/dev/null
                return
            else
                set cwd (path dirname "$cwd")
            end
        end
    end
    # If virtualenv activated but we are not in a git directory, deactivate.
    if test -n "$VIRTUAL_ENV"; and functions -q deactivate
        deactivate
    end
end
