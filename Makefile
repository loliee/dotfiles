SHELL := /usr/bin/env bash
PREZTO := ~/.zprezto
PATATETOY := ~/.patatetoy
.DEFAULT_GOAL := help

help:
	@grep -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

install: ## Setup a nice osx system, run all the following install tasks
	@make install-homebrew \
	install-dotfiles \
	install-tpm \
	install-prezto \
	install-vundle \

install-dotfiles: # Install my dotfiles, included patatetoy prompt
	$(info --> Install dotfiles)
	@[[ -d $(PATATETOY) ]] \
		|| git clone \
	https://github.com/loliee/patatetoy.git $(PATATETOY)
	@which stow >/dev/null || { echo'CAN I HAZ STOW ?'; exit 1; }
	@mkdir -p $(HOME)/.ssh/tmp && mkdir -p $(HOME)/.ssh/assh.d
	@ln -sf $(PWD)/.assh  $(HOME)/.ssh/assh.yml
	@stow -S . -t "$(HOME)" -v \
		--ignore='README.md' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='.media' \
		--ignore='.install.d' \
		--ignore='.DS_Store' \
		--ignore='.assh' \
		--ignore='.travis.yml' \
		--ignore='tests' \
		--ignore='.fzf_history' \
		--ignore='.fzf'

setup-iterm2: ## Configure iterm2 with patatetoy theme and great shortcut keys
	$(info --> Install iterm2)
	@ln -sf $(PWD)/.iterm2 ~/.iterm2
	@[[ -d ~/.iterm2/patatetoy-iterm2 ]] \
		|| git clone https://github.com/loliee/patatetoy-iterm2/ ~/.iterm2/patatetoy-iterm2
	@open ~/.iterm2/patatetoy-iterm2/patatetoy.itermcolors
	@defaults read ~/.iterm2/com.googlecode.iterm2 &>/dev/null

install-homebrew: ## Install homebrew and my list of packages
	$(info --> Install homebrew)
	@which brew &>/dev/null \
			|| ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
			@./.brew

install-tpm: ## Install tpm, the tmux plugin manager
	$(info --> Install tpm)
	@mkdir -p ~/.tmux/plugins
	@[[ -d ~/.tmux/plugins/tpm ]] \
		|| git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

install-prezto: ## Install prezto, the confuguration framework for Zsh
	$(info --> Install Prezto)
	@[[ -d $(PREZTO) ]] \
		|| git clone -q --depth 1 --recursive \
		https://github.com/sorin-ionescu/prezto.git $(PREZTO)

install-vundle:  ## Install vundle, the plug-in manager for Vim
	$(info --> Install Vundle)
	@mkdir -p ~/.vim/bundle/
	@[[ -d ~/.vim/bundle/Vundle.vim ]] \
		|| git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	@vim +PluginInstall +qall &>/dev/null
	@mkdir -p ~/.vim/undofiles
	@ln -sf $(PWD)/.vim-snippets  ~/.vim/UltiSnips

uninstall: ## Uninstall dotfiles, Tmux Tpm, Prezto, Vundle
	@make uninstall-dotfiles \
		uninstall-tpm \
		uninstall-prezto \
		uninstall-vundle

uninstall-dotfiles: ## Uninstall dotfiles and patatetoy prompt
	$(info --> Uninstall dotfiles)
	@rm -rf ~/.patatetoy
	@stow -D . -t "$(HOME)" -v \
		--ignore='README.md' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='.media' \
		--ignore='.install.d' \
		--ignore='.DS_Store' \
		--ignore='.assh' \
		--ignore='.travis.yml' \
		--ignore='tests' \
		--ignore='.fzf_history'

uninstall-tpm: ## Uninstall tmux plugin manager
	$(info --> Uninstall tpm)
	@[[ -d ~/.tmux/plugins/tpm ]] \
		&& rm -rf ~/.tmux/plugins/tmp

uninstall-prezto: ## Uninstall Prezto
	$(info --> Uninstall Prezto)
	@[[ -d $(PREZTO) ]] \
		&& rm -rf $(PREZTO)

uninstall-vundle: ## Uninstall Vundle
	$(info --> Uninstall vundle)
	@[[ -d ~/.vim/bundle/Vundle.vim ]] \
		&& rm -rf ~/.vim/bundle/Vundle.vim

test: ## Run tests suite
	$(info --> Run tests)
	@bats tests/*.bats
