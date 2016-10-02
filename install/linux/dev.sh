#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

INSTALL_SCRIPTS=$INSTALL_SCRIPTS
INSTALL_VIRTUALBOX=${INSTALL_VIRTUALBOX:-1}
INSTALL_SCRIPTS_LIST=(
  bats
  docker
  install-ruby
)

echo '--> Install dev packages'

# Node
curl -sL https://deb.nodesource.com/setup_6.x | bash -
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 \
            --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

apt-get update && apt-get install -y \
  bridge-utils \
  cdebootstrap \
  checkinstall \
  cmake \
  debian-installer-launcher \
  dkms \
  dnsutils \
  evtest \
  g++ \
  golang \
  graphviz \
  ipcalc \
  jq \
  libevent-dev \
  liblua5.2-dev \
  linux-headers-amd64 \
  live-build \
  live-tools \
  lua5.2 \
  nmap \
  nodejs \
  pandoc \
  python-dev \
  python-virtualenv \
  shellcheck \
  strace \
  tig \
  tcpdump \
  virt-manager \
  wireshark \
   --no-install-recommends

for app in "${INSTALL_SCRIPTS_LIST[@]}"; do
  "${INSTALL_SCRIPTS}/${app}/${app}.sh"
done

# Install virtualbox
[[ $INSTALL_VIRTUALBOX == 1 ]] && apt-get intall -y virtualbox &>/dev/null
