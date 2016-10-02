#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

GUEST_OS=${GUEST_OS:-0}
CUSER=${CUSER:='mloliee'}
INSTALL_SCRIPTS=$INSTALL_SCRIPTS
INSTALL_SCRIPTS_LIST=(
  albert
  chrome
  fzf
  fasd
  oracle-java8
  hack-font
  sshrc
  stow
  xfce-theme
)

apt-get update && apt-get install -y \
  ack-grep \
  ca-certificates \
  ecryptfs-utils \
  git-core \
  htop \
  iptables-persistent \
  libreoffice \
  keepass2 \
  keyboard-configuration \
  lftp \
  locales \
  ncdu \
  ntfs-3g \
  ntp \
  openssh-server \
  pwgen \
  rsync \
  sudo \
  terminator \
  transmission \
  unzip \
  xfce4-cpugraph-plugin \
  xfce4-netload-plugin \
  xfce4-systemload-plugin \
  zsh \
   --no-install-recommends

for app in "${INSTALL_SCRIPTS_LIST[@]}"; do
    "${INSTALL_SCRIPTS}/${app}/${app}.sh"
done
