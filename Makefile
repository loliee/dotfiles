SHELL := /usr/bin/env bash
PREZTO := ~/.zprezto
MLPURE := ~/.mlpure

install: install-dotfiles \
	install-tpm \
	install-prezto \
	install-vundle

uninstall: uninstall-dotfiles \
	uninstall-tpm \
	uninstall-prezto \
	uninstall-vundle

install-dotfiles:
	$(info --> Install dotfiles)
	@[[ -d $(MLPURE) ]] \
		|| git clone \
	https://github.com/loliee/mlpure.git $(MLPURE)
	@which stow >/dev/null || { echo 'CAN I HAZ STOW ?'; exit 1; }
	@stow -S . -t "$(HOME)" -v \
		--ignore='README.md' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='.media' \
		--ignore='.install.d' \
		--ignore='.DS_Store'

uninstall-dotfiles:
	$(info --> Uninstall dotfiles)
	@rm -rf ~/.mlpure
	@stow -D . -t "$(HOME)" -v \
		--ignore='README.md' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='.install.d' \
		--ignore='.DS_Store'

install-tpm:
	$(info --> Install tpm)
	@mkdir -p ~/.tmux/plugins
	@[[ -d ~/.tmux/plugins/tpm ]] \
		|| git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

uninstall-tpm:
	$(info --> Uninstall tpm)
	@[[ -d ~/.tmux/plugins/tpm ]] \
		&& rm -rf ~/.tmux/plugins/tmp

install-prezto:
	$(info --> Install Prezto)
	@[[ -d $(PREZTO) ]] \
		|| git clone -q --depth 1 --recursive \
		https://github.com/sorin-ionescu/prezto.git $(PREZTO)

uninstall-prezto:
	$(info --> Uninstall Prezto)
	@[[ -d $(PREZTO) ]] \
		&& rm -rf $(PREZTO)

install-vundle:
	$(info --> Install Vundle)
	@mkdir -p ~/.vim/bundle/
	@[[ -d ~/.vim/bundle/Vundle.vim ]] \
		|| git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	@vim +PluginInstall +qall &>/dev/null

uninstall-vundle:
	$(info --> Uninstall vundle)
	@[[ -d ~/.vim/bundle/Vundle.vim ]] \
		&& rm -rf ~/.vim/bundle/Vundle.vim

install-patatetoy-iterm2:
	$(info --> Uninstall patatetoy-iterm2)
	@[[ -d ~/.patatetoy-iterm2 ]] \
		|| git clone https://github.com/loliee/patatetoy-iterm2/ ~/.patatetoy-iterm2
	@open ~/.patatetoy-iterm2/patatetoy.itermcolors

uninstall-patatetoy-iterm2:
	$(info --> Uninstall patatetoy-iterm2)
	@[[ -d ~/.patatetoy-iterm2 ]] \
		&& rm -rf ~/.patatetoy-iterm2
