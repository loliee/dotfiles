#!/usr/bin/env bash

set -f

export INSTALL_SCRIPTS=${INSTALL_SCRIPTS:-'/usr/local/src/install-scripts'}

export DEBIAN_FRONTEND=noninteractive

echo -e "Detected system\n OS: ${OS_FAMILY}\n FAMILY: ${OS_FAMILY}"

[[ ! -f /etc/debian_version ]] && \
  echo 'not a debian system, exit ...' && \
  exit 0

echo '--> Install GNU/Linux system'
apt-get update
apt-get install -y apt-transport-https curl sudo

echo '--> Download install-scripts'
mkdir -p "$INSTALL_SCRIPTS" && \
      curl -L https://github.com/loliee/install-scripts/tarball/master \
      | tar -xzv -C "$INSTALL_SCRIPTS" --strip-components 1

if [[ $(id -u "${CUSER}") != '0' ]]; then
  echo "--> Create user ${CUSER}"
  sudo useradd -m \
    -d "${CHOME}" \
    -p "$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "${CPASSWORD}")" \
    -s /bin/zsh \
      "${CUSER}"
else
  echo "--> Update user ${CUSER}"
  sudo usermod \
    -d "${CHOME}" \
    -p "$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "${CPASSWORD}")" \
    -s /bin/zsh \
    "${CUSER}"
fi
if [[ ! -f "/etc/sudoers.d/99${CUSER}" ]]; then
  echo "${CUSER} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/99${CUSER}"
  chmod 0440 "/etc/sudoers.d/99${CUSER}"
fi

run_list_array=(${RUN_LIST//,/ })
# shellcheck source=/dev/null
for i in "${!run_list_array[@]}"; do
  echo "--> Install ${run_list_array[i]} packages"
  "./install/linux/${run_list_array[i]}.sh"
done

echo '--> Upgrade packages'
apt-get upgrade -y

echo '--> Setup GNU/Linux !'
./install/linux/settings.sh

echo '--> Purge apt files'
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
apt-get clean
