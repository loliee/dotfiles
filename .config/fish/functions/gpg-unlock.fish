function gpg-unlock -d "Load the GPG subkeys passphrase from 1Password into gpg-agent"
    set -l passphrase (op read "op://Private/GPG subkeys/password"); or return 1
    set -l keygrips (gpg --with-colons --with-keygrip --list-secret-keys 3B05E29108F575D45022E3EBAE95106F1B5A0D7E | string match -rg '^grp:+([0-9A-F]+):'); or return 1

    for keygrip in $keygrips
        # printf is a fish builtin: the passphrase never appears in a process argument list
        printf '%s\n' $passphrase | /opt/homebrew/opt/gnupg/libexec/gpg-preset-passphrase --preset $keygrip; or return 1
    end
end
