function timew-restore -d "Replace the Timewarrior data with the archive attached to the 1Password note Timewarrior"
    set -l dir $HOME/.local/share/timewarrior
    __opx_signin; or return 1

    set -l tmp (mktemp -d); or return 1
    set -l restored 1
    if not __opx_op read --out-file $tmp/timewarrior.tar.gz op://Private/Timewarrior/timewarrior.tar.gz >/dev/null
        print-err "[timew-restore] cannot read the archive of the note Timewarrior"
    else if not tar -xzf $tmp/timewarrior.tar.gz -C $tmp data
        print-err "[timew-restore] cannot extract data from the archive"
    else if read -l -P "[timew-restore] replace $dir/data with the 1Password backup? [y/N] " answer; and string match -qir '^y' -- $answer
        mkdir -p $dir
        and rm -rf $dir/data
        and mv $tmp/data $dir/data
        and set restored 0
        and echo "✔  $dir/data restored"
    end
    rm -rf $tmp
    return $restored
end
