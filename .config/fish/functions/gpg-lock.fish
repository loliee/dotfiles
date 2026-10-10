function gpg-lock -d "Forget the passphrases cached by gpg-agent"
    gpgconf --reload gpg-agent
end
