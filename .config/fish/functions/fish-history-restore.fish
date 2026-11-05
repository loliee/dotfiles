function fish-history-restore --argument-names host -d "Replace the fish history with the one attached to the 1Password note of this machine, or of the given one"
    set -l file $XDG_DATA_HOME/fish/fish_history
    test -n "$host"; or set host (hostname)
    __opx_signin; or return 1

    set -l tmp (mktemp -d); or return 1
    set -l restored 1
    if not __opx_op read --out-file $tmp/fish_history op://Private/$host/fish_history >/dev/null
        print-err "[fish-history-restore] cannot read the history of the note $host"
    else if read -l -P "[fish-history-restore] replace $file with the history of $host? [y/N] " answer; and string match -qir '^y' -- $answer
        mv $tmp/fish_history $file
        and set restored 0
        and echo "✔  $file restored from $host"
        and history merge
    end
    rm -rf $tmp
    return $restored
end
