# ~/.dotfiles

[![Build Status](https://github.com/loliee/dotfiles/actions/workflows/lint.yml/badge.svg)](https://github.com/loliee/dotfiles/actions)

This repository contains my personal configuration files and setup scripts.
Feel free to browse for inspiration, but these are tailored for my workflow and environment.

## Getting Started

Clone the repository:

```bash
git clone https://github.com/loliee/dotfiles ~/.dotfiles
```

Alternatively, download as a tarball:

```bash
mkdir -p ~/.dotfiles
curl -L https://github.com/loliee/dotfiles/tarball/master \
  | tar -xzv -C ~/.dotfiles --strip-components 1 --exclude={README.md}
```

## Installation

Dotfiles and packages are managed using `make` and `stow`.

### Common Commands

- **make install**: Installs all required packages and dotfiles.
- **make install-dotfiles**: Installs only the dotfiles, skipping packages.
- **make help**: Lists all available `make` commands with descriptions.

## macOS Setup

My macOS setup scripts apply personal preferences and security tweaks:

```bash
make setup-macos
make setup-macos-hardening
```

## Fish Shell

Set Fish as default shell (macOS example):

```bash
echo "$(brew --prefix)/bin/fish" | sudo tee -a /etc/shells
chsh -s "$(brew --prefix)/bin/fish"
```

## Resources

- [Apple Official manual page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/defaults.1.html)
- [OS X Security and Privacy Guide](https://github.com/drduh/OS-X-Security-and-Privacy-Guide#http)

---

> **Note:** These dotfiles are not intended as a plug-and-play solution for others.
> Please review and modify for your own needs before using.
