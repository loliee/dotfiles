#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

echo '--> Install multimedia packages'

apt-get install -y \
  gimp \
  imagemagick \
  jpegoptim \
  optipng \
  vlc \
   --no-install-recommends
