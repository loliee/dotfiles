#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

INSTALL_DNS=${INSTALL_DNS:-0}
INSTALL_PROXY=${INSTALL_PROXY:-0}

hash brew &>/dev/null \
     || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

"./.install.d/${OS}/brew.sh"
[[ $INSTALL_DNS == 1 ]] && "./.install.d/${OS}/dns.sh"
[[ $INSTALL_PROXY == 1 ]] && "./.install.d/${OS}/http_proxy.sh"
