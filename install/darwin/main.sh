#!/usr/bin/env bash
#
# Install  packages for macOS
#
# Packages are divided by the following groups:

set -f

# RUN_GROUP_LIST
# - base: install minimum package for running my os
# - dev: install dev/ops packages, e.g docker, virtualbox, charles...
# - dns: install/setup dnsmasq and dnscrypt-proxy
# - messaging: install messaging tools, e.g skype, slack...
# - multimedia: install multimedia packages, e.g vlc, gimp etc...
# - http_proxy: install/setup polip proxy usefull for weak network

RUN_LIST=${RUN_LIST:-'base,dev,dns,messaging,multimedia,http_proxy'}

# Run osx settings script

SETUP_MACOS=${SETUP_MACOS:-1}

# Link Homebrew casks in `/Applications` rather than `~/Applications`
export HOMEBREW_CASK_OPTS='--appdir=/Applications --no-binaries'

echo '--> Check for Homebrew'
if [[ ! $(which brew) ]]; then
  echo '--> Installing homebrew...'
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "--> Make sure we're using the latest Homebrew"
brew update

echo '--> Upgrade any already-installed formulae'
brew upgrade

echo '--> Tap extras Homebrew repositories'
brew tap caskroom/cask
brew tap caskroom/fonts
brew tap homebrew/services
brew tap tldr-pages/tldr

run_list_array=(${RUN_LIST//,/ })
# shellcheck source=/dev/null
for i in "${!run_list_array[@]}"; do
  echo "--> Install ${run_list_array[i]} packages"
  "./install/darwin/${run_list_array[i]}.sh"
done

echo '--> Link homebrew apps'
brew linkapps

echo '--> Cleanup !'
brew cask cleanup
brew cleanup

# Fix zsh completion directory
mkdir -p /usr/local/share/zsh /usr/local/share/zsh/site-functions
chmod 755 /usr/local/share/zsh /usr/local/share/zsh/site-functions

if [[ $SETUP_MACOS == 1 ]]; then
  echo '--> Setup macOS !'
  ./install/darwin/settings.sh
fi
