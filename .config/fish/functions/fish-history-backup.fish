function fish-history-backup -d "Attach the fish history to the 1Password note named after the machine"
    set -l file $XDG_DATA_HOME/fish/fish_history
    set -l note (hostname)
    __opx_signin; or return 1

    if not __opx_op item edit $note --vault Private 'fish_history[file]='$file >/dev/null
        print-err "[fish-history-backup] cannot attach $file to the note $note"
        return 1
    end
    echo "✔  $file attached to the note $note"
end
