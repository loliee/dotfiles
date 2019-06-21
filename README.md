# ~/.dotfiles

[![Build Status](https://travis-ci.org/loliee/dotfiles.svg?branch=master)](https://travis-ci.org/loliee/dotfiles)

## Get this repository

```bash
git clone https://github.com/loliee/dotfiles ~/.dotfiles
```

Or without git (useful for the first install)

```bash
mkdir -p ~/.dotfiles
curl -L https://github.com/loliee/dotfiles/tarball/master \
| tar -xzv -C ~/.dotfiles --strip-components 1 --exclude={README.md}
```

## Install

Install brew, a lot of awesome packages 📦 and super sweet dotfiles ✨

```bash
# Install dotfiles and packages
make install

# Install only dotfiles
make install-dotfiles

# Or limit packages with the `RUN_LIST`
# Possible values are `base,dev,messaging,multimedia,privacy`
RUN_LIST='messaging,multimedia,privacy' \
  make install

# Need help ?
make help
```

## MacOS

Setup sensible macOS defaults with:

```bash
make setup-macos
make setup-macos-hardening
```

## Zsh

Define zsh as your default shell (example bellow is macOS specific):

```
echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells
chsh -s "$(brew --prefix)/bin/zsh"
```

## Uninstall

Remove dotfiles and packages with:

```bash
make uninstall-dotfiles
make uninstall-brew
```

## Ressources

- [Apple Official manual page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/defaults.1.html).
- [OS X Security and Privacy Guide](https://github.com/drduh/OS-X-Security-and-Privacy-Guide#http)
- [Mathias’s dotfiles](https://github.com/mathiasbynens/dotfiles)
