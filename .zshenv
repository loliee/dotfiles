# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

if [[ -s "${HOME}/.homebrew/share/zsh/site-functions" ]]; then
  fpath=( "${HOME}/.homebrew/share/zsh/site-functions" $fpath )
fi

if [[ -d "${HOME}/.zsh/completion" ]]; then
  fpath=( "${HOME}/.zsh/completion" $fpath )
fi

# Source Prompt theme.
if [[ -s "${ZDOTDIR:-$HOME}/.patatetoy/" ]]; then
  fpath=( "${ZDOTDIR:-$HOME}/.patatetoy/" $fpath )
fi
