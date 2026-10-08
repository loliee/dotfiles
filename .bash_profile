# shellcheck shell=bash
# shellcheck disable=SC1090
if [[ -f "${HOME}/.bashrc" ]]; then
  # shellcheck source=/dev/null
  . "${HOME}/.bashrc"
fi
