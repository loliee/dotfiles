#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

OS="$(uname)"
OS_FAMILY=$(uname -a)

export OS \
       OS_FAMILY

echo "--> Run ${OS} install script..."

"./.install.d/${OS}/install.sh"
