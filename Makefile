SHELL := /usr/bin/env bash
PREZTO := ~/.zprezto
MLPURE := ~/.mlpure
VUNDLE := ~/.vim/bundle/Vundle.vim

install: install-dotfiles

install-dotfiles:
		@[[ -d $(VUNDLE) ]] || \
			git clone \
		https://github.com/VundleVim/Vundle.vim.git $(VUNDLE)
		@[[ -d $(MLPURE) ]] || \
			git clone \
		https://github.com/loliee/mlpure.git $(MLPURE)
		@[[ -d $(PREZTO) ]] || \
			git clone -q --depth 1 --recursive \
		https://github.com/sorin-ionescu/prezto.git $(PREZTO)
			@git pull -q && git submodule update --init --recursive -q
	@which stow >/dev/null || { echo 'CAN I HAZ STOW ?'; exit 1; }
	@stow -S . -t "$(HOME)" -v \
		--ignore='README.md' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='.media' \
		--ignore='.DS_Store'

uninstall: uninstall-dotfiles

uninstall-dotfiles:
	@stow -D . -t "$(HOME)" -v \
		--ignore='README.md' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='.install.d' \
		--ignore='.DS_Store'
