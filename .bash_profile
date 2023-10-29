# shellcheck shell=bash
# shellcheck disable=SC1090
if [[ -f "${HOME}/.profile" ]]; then
  # shellcheck source=/dev/null
  . "${HOME}/.profile"
fi

if [[ -f "${HOME}/.bashrc" ]]; then
  # shellcheck source=/dev/null
  . "${HOME}/.bashrc"
fi
