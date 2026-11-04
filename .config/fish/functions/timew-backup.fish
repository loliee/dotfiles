function timew-backup -d "Attach the Timewarrior data to the 1Password note Timewarrior"
    set -l dir $HOME/.local/share/timewarrior
    __opx_signin; or return 1

    set -l archive (mktemp); or return 1
    tar -czf $archive -C $dir data
    # op assignment syntax: an unescaped . separates a section from the field
    and __opx_op item edit Timewarrior --vault Private 'timewarrior\.tar\.gz[file]='$archive >/dev/null
    set -l saved $status
    rm -f $archive
    if test $saved -ne 0
        print-err "[timew-backup] cannot attach $dir/data to the note Timewarrior"
        return 1
    end
    echo "✔  $dir/data attached to the note Timewarrior"
end
