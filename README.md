# ~/.dotfiles

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

## Dotfiles setup

Using [GNU Stow](http://www.gnu.org/software/stow/):

### Installation

```bash
cd ~/.dotfiles
make install
```

check [make arguments](#Make arguments) for details

### Uninstallation

```bash
make uninstall
```

## Mac setup

Install [Xcode](https://itunes.apple.com/fr/app/xcode/id497799835?mt=12) first.

### Install Homebrew Formulae/Native apps

```bash
./.brew
```

### Sensible OS X defaults

When setting up a new Mac, you may want to set some sensible OS X defaults:

```bash
./.osx
```

:warning: **this install `dnscrypt-proxy` and `dnsmasq` and setup `127.0.0.1` as DNS server, remove this in network settings if issues or do better update your conf ;)**

### Install iterm2 colors scheme

Install [patatetoy](https://github.com/loliee/patatetoy-iterm2) theme.

```bash
make install-patatetoy-iterm2
```

To enable, `iterm2 preferences > colors > Load Presets` and select `patatetoy`.

### Ressources

- [Apple Official manual page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/defaults.1.html)
- [OS X Security and Privacy Guide](https://github.com/drduh/OS-X-Security-and-Privacy-Guide#http)

**List defaults**

```bash
rc="\n" && defaults domains | sed s/,/"$rc"/g
```

**Read default values**

```bash
defaults read com.apple.mail
```

## Make arguments

```bash
make [arg]
```

[arg]                 | Description
--------------------- | ---------------------------------------
install               | Install local environment, execute: `install-dotfiles` `install-tpm` `install-prezto` `install-vundle`
uninstall             | Uninstall local envir `uninstall-dotfiles` `uninstall-tpm` `uninstall-prezto` `uninstall-vundle`
install-dotfiles      | Install only dotfiles + [mlpure zsh prompt](https://github.com/loliee/mlpure).
uninstall-dotfiles    | Uninstall dotfiles + [mlpure zsh prompt](https://github.com/loliee/mlpure).
install-tpm           | Install only [tmux plugins](https://github.com/tmux-plugins/tpm).
install-prezto        | Install [prezto for zsh](https://github.com/sorin-ionescu/prezto).
install-vundle        | Install only [vundle plugin manager for vim](https://github.com/VundleVim/Vundle.vim).
uninstall-tpm         | Uninstall [tmux plugins](https://github.com/tmux-plugins/tpm).
uninstall-prezto      | Uninstall [prezto for zsh](https://github.com/sorin-ionescu/prezto).
uninstall-vundle      | Uninstall [vundle plugin manager for vim](https://github.com/VundleVim/Vundle.vim).
install-patatetoy-iterm2 **OSX only** | Install iterm2 [patatetoy](https://github.com/loliee/patatetoy-iterm2) theme. To enable, `iterm2 preferences > colors > Load Presets` and select `patatetoy`.
uninstall-patatetoy-iterm2 **OSX only** | Uninstall iterm2 [patatetoy](https://github.com/loliee/patatetoy-iterm2) theme.

## Todo

  - OSX remap caplocks to ctrl
  - Setup divvy
  - Setup avatar correctly
  - Check active corner
  - Setup istat menu and info bar
  - Disable guest account
