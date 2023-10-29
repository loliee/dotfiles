# ~/.dotfiles

## Get this repository

```console
git clone https://github.com/loliee/dotfiles ~/.dotfiles
```

Or without git (useful for the first install)

```console
mkdir -p ~/.dotfiles
curl -L https://github.com/loliee/dotfiles/tarball/master \
| tar -xzv -C ~/.dotfiles --strip-components 1 --exclude={README.md}
```

## Install

Install packages 📦 and dotfiles ✨.

```console
# Install packages and dotfiles
make install

# Install only dotfiles
make install-dotfiles

# Need help ?
make help
```

## MacOS

Setup sensible macOS defaults with:

```console
make setup-macos
make setup-macos-hardening
```

## Fish

Define fish as your default shell (example bellow is macOS specific):

```console
echo "$(brew --prefix)/bin/fish" | sudo tee -a /etc/shells
chsh -s "$(brew --prefix)/bin/fish"
```

## Resources

- [Apple Official manual page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/defaults.1.html).
- [OS X Security and Privacy Guide](https://github.com/drduh/OS-X-Security-and-Privacy-Guide#http)
- [Benji’s dotfiles](https://github.com/bdossantos/dotfiles)
- [Mathias’s dotfiles](https://github.com/mathiasbynens/dotfiles)
- [Gary's dotfiles](https://github.com/garybernhardt/dotfiles)
- [Tim's dotfiles](https://github.com/tpope/tpope)
