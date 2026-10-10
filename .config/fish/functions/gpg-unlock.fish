function gpg-unlock -d "Cache the passphrase of git's signing key now, through pinentry-op"
    set -l key (git config --get user.signingkey)
    if test -z "$key"
        print-err "[gpg-unlock] git config has no user.signingkey"
        return 1
    end

    # A throwaway signature makes gpg-agent call pinentry-op unless the passphrase is already cached
    gpg --local-user $key --output - --detach-sign /dev/null >/dev/null
end
