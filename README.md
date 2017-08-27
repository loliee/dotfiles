# ~/.dotfiles

[![Build Status](https://travis-ci.org/loliee/dotfiles.svg?branch=master)](https://travis-ci.org/loliee/dotfiles)

## Install

### Git install

```bash
git clone https://github.com/loliee/dotfiles ~/.dotfiles
```

### Git-free install

To install these dotfiles without Git:

```bash
mkdir -p ~/.dotfiles; curl -L https://github.com/loliee/dotfiles/tarball/master | tar -xzv -C ~/.dotfiles --strip-components 1 --exclude={README.md}
```

To update later on, just run that command again.

## Setup (only) dotfiles

Using [GNU Stow](http://www.gnu.org/software/stow/):

### Installation

```bash
cd ~/.dotfiles
make install-dotfiles
```

### Uninstallation

```bash
make uninstall-dotfiles
```

## Setup full OS

Provision `macOS` system with [brew](http://brew.sh/) packages I use.

```bash
./install.sh
```

### Configuration

#### `INSTALL_DOTFILES`

Install dotfiles in current user `HOME` directory, default to `1`.

#### `OS`

In some case `OS` detection fail, define `$OS` var with `darwin` or `linux`.

#### `RUN_LIST`

Group of packages to install, default to `base,dev,dns,messaging,multimedia,http_proxy`.

#### `INSTALL_GPGTOOLS`

Install `gpgtools` and `keybase` packages, default to `1` (disabled during tests).

## Ressources

### macOS

- [Apple Official manual page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/defaults.1.html).
- [OS X Security and Privacy Guide](https://github.com/drduh/OS-X-Security-and-Privacy-Guide#http).

**List defaults: **

```bash
rc="\n" && defaults domains | sed s/,/"$rc"/g
```

**Read default values: **

```bash
defaults read com.apple.mail
```
