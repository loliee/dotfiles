# ~/.dotfiles

## Dotfiles setup

Using [GNU Stow](http://www.gnu.org/software/stow/):

```bash
git clone https://github.com/loliee/dotfiles ~/.dotfiles
cd ~/.dotfiles
```

### Installation

```bash
make install
```

check [make arguments](#Make arguments) for details

### Uninstallation

```bash
make uninstall
```

## Mac setup

Install [Xcode](https://itunes.apple.com/fr/app/xcode/id497799835?mt=12) first.

### Sensible OS X defaults

When setting up a new Mac, you may want to set some sensible OS X defaults:

```bash
./.osx
```

### Install Homebrew Formulae/Native apps

```bash
make install-homebrew
```

:warning: **this install `dnscrypt-proxy` and `dnsmasq` and setup `127.0.0.1` as DNS server, remove this in network settings if issues or do better update your conf ;)**

### UnInstall Homebrew

```bash
make uninstall-homebrew
```

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
install-homebrew      | For **OSX only** install [homebrew](https://github.com/Homebrew/homebrew), homebrew packages and setup some services like dnsmasq, dnscrypt-proxy...
uninstall-homebrew    | Uninstall homebrew, not clean at all :(

## Todo

  - OSX remap caplocks to ctrl
  - Setup divvy
  - Setup avatar correctly
  - Check active corner
  - Setup istat menu and info bar
  - Disable guest account
