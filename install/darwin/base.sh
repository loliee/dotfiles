#!/usr/bin/env bash

INSTALL_GPGTOOLS=${INSTALL_GPGTOOLS:-1}

echo '--> Install/update base Homebrew cask'
brew cask install font-hack
brew cask install flux
brew cask install google-chrome
brew cask install google-drive
[[ $INSTALL_GPGTOOLS == 1 ]] && brew cask install gpgtools
brew cask install istat-menus
brew cask install iterm2
brew cask install java
brew cask install keepassx
brew cask install osxfuse
brew cask install xquartz

# Replace macOS openssl version
brew install openssl && brew link openssl --force

brew install advancecomp
brew install ansifilter
brew install autoenv
brew install homebrew/fuse/bindfs
brew install coreutils
brew install curl --with-openssl && brew link --force curl
brew install dnscrypt-proxy
brew install dnsmasq
brew install fasd
brew install findutils
brew install fzf
brew install git
brew install gnu-sed --with-default-names
brew install gnu-tar
brew install gnu-time
brew install gsl
brew install htop-osx
brew install keybase
brew install moreutils
brew install ncdu
brew install ntfs-3g
brew install openssh
brew install pigz
brew install polipo
brew install pwgen
brew install readline
brew install reattach-to-user-namespace
brew install ssh-copy-id
brew install sshrc
brew install stow
brew install tag
brew install terminal-notifier
brew install the_silver_searcher
brew install tmux
brew install tmux-cssh
brew install tree
brew install tmux-mem-cpu-load
brew install vim --with-python3
brew install watch
brew install wget
brew install xz
brew install zopfli
brew install zsh-syntax-highlighting
brew install zsh
brew install tldr
