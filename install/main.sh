#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Install dotfiles, default 1 to disable set 0
export INSTALL_DOTFILES=${INSTALL_DOTFILES:-1}
export OS=${OS:-"$(uname | awk '{ print tolower($1) }')"}
export OS_FAMILY=${OS_FAMILY:-$(uname -a)}

echo "--> Run ${OS} install scripts..."
"./install/${OS}/main.sh"
./install/common/main.sh
