#!/usr/bin/env bash
#
# Install multimedia packages for macOS
#
# e.g: image manipulation, video etc ...

echo '--> Install multimedia cask apps'
brew cask install imageoptim
brew cask install gimp
brew cask install transmission
brew cask install vlc

echo '--> Install multimedia apps'
brew install gifsicle
brew install graphviz
brew install jhead
brew install jpeg
brew install jpegoptim
brew install optipng
brew install pngcrush
brew install pngquant
brew install webkit2png
