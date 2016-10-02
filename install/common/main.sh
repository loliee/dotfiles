#!/usr/bin/env bash
#
# Install common script/packages

# Install followinf dotfiles in $HOME
DOTFILES=(
  .Xmodmap
  .config
  .aliases
  .aliases.dev
  .aliases.osx
  .bashrc
  .curlrc
  .editorconfig
  .gemrc
  .gitconfig
  .gitignore
  .gitignore-global
  .gitmessage
  .hushlogin
  .iterm2
  .macos
  .profile
  .sshrc
  .sshrc.d
  .tigrc
  .tmux.conf
  .vimrc
  .vimrc.min
  .xinitrc
  .xsession
  .zlogin
  .zlogout
  .zpreztorc
  .zprofile
  .zshenv
  .zshrc
)

echo "--> Setup dofiles for user: ${CUSER}"
if [[ $INSTALL_DOTFILES == 1 ]]; then
  backup_dir="${CHOME}/.backup/$(date -u +"%Y-%m-%dT%H%M")"
  echo "Backup dotfiles in ${backup_dir}"
  mkdir -p "${backup_dir}"
  for file in "${DOTFILES[@]}"; do
    echo "${CHOME}/${file}"
		[[ -f "${CHOME}/${file}" ]] && mv "${CHOME}/${file}" "${backup_dir}/"
  done

  make install-dotfiles
fi

if [[ $OS == "darwin" ]]; then
  echo '--> Setup Iterm'
  make setup-iterm2
fi

# Install kubectl completion
# shellcheck disable=SC2015
hash kubectl &>/dev/null && kubectl completion zsh \
     > /usr/local/share/zsh/site-functions/_kubectl \
     || true

# Install travis completion
# shellcheck disable=SC2015
hash travis &>/dev/null  && \
     curl -Lso /usr/local/share/zsh/site-functions/_travis \
            https://raw.githubusercontent.com/travis-ci/travis.rb/master/assets/travis.sh \
     || true
