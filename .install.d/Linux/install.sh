#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

OS=$OS
OS_FAMILY=$OS_FAMILY

echo -e "Detected system\n OS: ${OS_FAMILY}\n FAMILY: ${OS_FAMILY}"

[[ ! -f /etc/debian_version ]] && \
  echo 'not a debian system, exit ...' && \
  exit 0

echo 'provision Debian system...'
"./.install.d/${OS}/debian.sh"
