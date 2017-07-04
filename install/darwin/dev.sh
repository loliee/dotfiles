#!/usr/bin/env bash
#
# Install my dev/ops packages

brew tap jeffreywildman/homebrew-virt-manager

echo '--> Install dev cask apps'
brew cask install charles
brew cask install google-cloud-sdk
brew cask install docker
brew cask install vagrant
brew cask install virtualbox

echo '--> Install dev apps'
brew install bats
brew install bfg
brew install chruby
brew install cloc
brew install closure-compiler
brew install ctags
brew install diff-so-fancy
brew install kubernetes-cli
brew install go
brew install hub
brew install ipcalc
brew install hadolint
brew install jq
brew install kubectl
brew install libxml2 && brew link libxml2 --force
brew install nodejs --with-full-icu
brew install nmap
brew install packer
brew install pandoc
brew install pgcli
brew install pre-commit
brew install python --with-brewed-openssl
brew install python3 --with-brewed-openssl
brew install pv
brew install qemu
brew install ruby-install
brew install s3cmd
brew install shellcheck
brew install spark
brew install svn
brew install tag
brew install tig
brew install tcpdump
brew install tcptraceroute
brew install terraform
brew install terraform-inventory

# Python

PIPS=(
  fabric
  flake8
  pylint
  virtualenv
)

"$(brew --prefix)/bin/pip" install --upgrade pip

for pip in "${PIPS[@]}"; do
  "$(brew --prefix)/bin/pip" list -l | grep "$pip" &>/dev/null || \
    "$(brew --prefix)/bin/pip" install "$pip"
done

# Ruby
mkdir -p ~/.rubies
RUBIES=(
  2.4.1
)

for ruby in "${RUBIES[@]}"; do
  "$(brew --prefix)/bin/ruby-install" --no-reinstall --rubies-dir ~/.rubies \
    ruby "$ruby" -- --disable-install-rdoc
done

echo "${RUBIES[@]:(-1)}" > ~/.ruby-version

GEMS=(
  bundler
  serverspec
  travis
)

# shellcheck source=/dev/null
source "$(brew --prefix)/share/chruby/chruby.sh"
chruby "$(cat ~/.ruby-version)"

for gem in "${GEMS[@]}"; do
  gem list -i "${gem}" &>/dev/null || gem install "${gem}"
done

