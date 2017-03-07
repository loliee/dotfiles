#!/usr/bin/env bash
#
# Provision macOS/Linux and install my dotfiles

set -o errexit
set -o pipefail
set -o nounset

# Install dotfiles, default 1 to disable set 0
export INSTALL_DOTFILES=${INSTALL_DOTFILES:-1}

# OS name [linux|darwin], default is uname lowercased
export OS=${OS:-$(uname | awk '{ print tolower($1) }')}

# OS family, default uname -a
export OS_FAMILY=${OS_FAMILY:-$(uname -a)}

# Username of user you want to configure
export CUSER=${CUSER:-'root'}

# User home
export CHOME=${CHOME:-'/root'}

# User password
export CPASSWORD=${CPASSWORD:-'packer'}

# Group of packages to install
export RUN_LIST=${RUN_LIST:-'base,dev,dns,messaging,multimedia,http_proxy'}

# Expand PATH
export PATH=/home/${CUSER}/bin:/usr/local/bin/:${PATH}

echo "--> Run ${OS} install scripts..."
"./install/${OS}/main.sh"
"./install/common/main.sh"
chown -R "${CUSER}" "${CHOME}"
