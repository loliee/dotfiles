#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

DISTRIB=${DISTRIB:-}
OS=${OS:-}
export PATH=$HOME/bin:$PATH

# Run install/tests on current host
if [[ -z $DISTRIB ]]; then
  ./install.sh
  make test
  exit "$?"

# Run install/tests in docker container
else
  CONTAINER_NAME=${DISTRIB/:/-}-${RUN_LIST/,/-}
  echo "--> Run docker ${CONTAINER_NAME}"

  docker run -d \
    -w='/root' \
    --name "${CONTAINER_NAME}" \
    --volume "${PWD}:/root/.dotfiles" \
    --env "DISTRIB=${DISTRIB}" \
    --env "INSTALL_DOTFILES=${INSTALL_DOTFILES}" \
    --env "INSTALL_VIRTUALBOX=${INSTALL_VIRTUALBOX}" \
    --env "RUN_LIST=${RUN_LIST}" \
    --env "OS=${OS}" \
    "${DISTRIB}" \
      tail -f /dev/null

  docker exec --user root "${CONTAINER_NAME}" \
    bash -c "apt-get update \
      && apt-get install -y build-essential sudo rubygems \
      && gem install serverspec rake"

  docker exec --user root "${CONTAINER_NAME}" \
    bash -c "pushd /root/.dotfiles; \
      ./install.sh; \
      make test; \
      popd;"

  docker rm -f "${CONTAINER_NAME}"
fi
