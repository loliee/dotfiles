#!/usr/bin/env bash

# Link Homebrew casks in `/Applications` rather than `~/Applications`
export HOMEBREW_CASK_OPTS='--appdir=/Applications --caskroom=/usr/local/Caskroom'

echo '--> Check for Homebrew'
if [[ ! $(which brew) ]]; then
  echo '--> Installing homebrew...'
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "--> Make sure we're using the latest Homebrew"
brew update

echo '--> Upgrade any already-installed formulae'
brew upgrade --all

echo '--> Install/update Homebrew cask'
brew cask update

echo '--> Tap extras Homebrew repositories'
brew tap caskroom/fonts
brew tap homebrew/services
brew tap homebrew/binary
brew tap homebrew/devel-only
brew tap homebrew/dupes
brew tap homebrew/versions
brew tap jeffreywildman/homebrew-virt-manager
brew tap tldr-pages/tldr

echo '--> Install cask apps'

brew cask install charles
brew cask install flux
brew cask install font-hack
brew cask install gimp
brew cask install google-chrome
brew cask install google-hangouts
brew cask install google-drive
brew cask install gpgtools
brew cask install imageoptim
brew cask install istat-menus
brew cask install iterm2
brew cask install java
brew cask install keepassx
brew cask install osxfuse
brew cask install paragon-extfs
brew cask install paragon-ntfs
brew cask install skype
brew cask install slack
brew cask install transmission
brew cask install vagrant
brew cask install virtualbox
brew cask install vlc
brew cask install xquartz

echo '--> Install brew apps'

# Install openssl first
brew install openssl && brew link openssl --force

brew install advancecomp
brew install ansifilter
brew install autoenv
brew install bats
brew install bfg
brew install homebrew/fuse/bindfs
brew install chruby
brew install cloc
brew install closure-compiler
brew install coreutils
brew install ctags
brew install curl --with-openssl && brew link --force curl
brew install diff-so-fancy
brew install dnscrypt-proxy
brew install dnsmasq
brew install docker docker-compose docker-machine
brew install fasd
brew install findutils
brew install fzf
brew install gifsicle
brew install git
brew install gnu-sed --with-default-names
brew install gnu-tar
brew install gnu-time
brew install go
brew install graphviz
brew install gsl
brew install hadolint
brew install htmlcompressor --yuicompressor
brew install htop-osx
brew install hub
brew install ipcalc
brew install jq
brew install imagemagick --with-webp
brew install jhead
brew install jpeg
brew install jpegoptim
brew install keybase
brew install kubectl
brew install libxml2 && brew link libxml2 --force
brew install moreutils
brew install ncdu
brew install nodejs --with-full-icu
brew install nmap
brew install optipng
brew install openssh
brew install packer
brew install pandoc
brew install pgcli
brew install pigz
brew install pngcrush
brew install pngquant
brew install polipo
brew install pre-commit
brew install pt
brew install pv
brew install pwgen
brew install python --with-brewed-openssl
brew install python3 --with-brewed-openssl
brew install readline
brew install reattach-to-user-namespace
brew install ruby-install
brew install s3cmd
brew install shellcheck
brew install spark
brew install ssh-copy-id
brew install sshrc
brew install stow
brew install svn
brew install tag
brew install terraform
brew install https://raw.github.com/adammck/terraform-inventory/master/homebrew/terraform-inventory.rb
brew install terminal-notifier
brew install tmux
brew install tcpdump
brew install tcptraceroute
brew install the_silver_searcher
brew install tig
brew install tldr
brew install tmux-cssh
brew install tmux-mem-cpu-load
brew install tree
brew install virt-manager
brew install virt-viewer
brew install vim
brew install watch
brew install webkit2png
brew install wget
brew install xz
brew install zopfli
brew install zsh-syntax-highlighting
brew install zsh

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

# ruby
mkdir -p ~/.rubies
RUBIES=(
  2.3.0
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

# npm
npm install -g js-yaml
npm install -g jshint
npm install -g doctoc

echo '--> Link homebrew apps'
brew linkapps

echo '--> Cleanup !'
brew cask cleanup
brew cleanup
