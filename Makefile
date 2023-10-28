MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables
DOTFILES_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OS = $(shell uname)
PREZTO := ~/.zprezto
SHELL := /usr/bin/env bash
PATH := $(HOME)/.homebrew/bin/:$(PATH)
VIRTUALENV_DIR := $(DOTFILES_DIR)/venv

.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.ONESHELL:
.PHONY: install test
.SHELLFLAGS := -eu -o pipefail -c

help:
	@grep -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

install: ## Full install
	@if [[ "$(OS)" == "Darwin" ]]; then \
		make install-brew; \
	fi
	make install-dotfiles

install-brew: # Install brew and packages
	@bash -x ./.brew

install-dev: ## Install test environment
	@if [[ "$(OS)" == "Darwin" ]]; then \
		brew install shellcheck; \
	fi
	@$(MAKE) -j 2 \
		install-gems \
		install-pip-packages;

install-dotfiles: ## Install my dotfiles
	$(info --> Install dotfiles)
	@command -v stow >/dev/null || { echo'CAN I HAZ STOW ?'; exit 1; }
	@stow -S . -t "$(HOME)" -v \
		--ignore='.DS_Store' \
		--ignore='.fzf_history' \
		--ignore='.gemrc' \
		--ignore='.git' \
		--ignore='.brew' \
		--ignore='.macos' \
		--ignore='.macos_hardening' \
		--ignore='.hadolint.yml' \
		--ignore='.travis.yml' \
		--ignore='.nvim' \
		--ignore='.vim' \
		--ignore='.yamllint' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='README.md' \
		--ignore='k9s' \
		--ignore='spec' \
		--ignore='venv'
	@mkdir -p \
		$(HOME)/.gnupg \
		$(HOME)/.vim \
		$(HOME)/.config/yamllint
	@chmod 700 $(HOME)/.gnupg
	@[[ -d $(HOME)/.config ]] \
		|| mkdir $(HOME).config
	@[[ -f $(HOME)/.config/hadolint.yaml ]] \
		|| ln -sf $(PWD)/.hadolint.yml $(HOME)/.config/hadolint.yaml
	@[[ -d $(HOME)/.config/k9s ]] \
		|| ln -sf $(PWD)/k9s $(HOME)/.config/k9s
	@[[ -f $(HOME)/.config/starship.toml ]] \
		|| ln -sf $(PWD)/.config/starship.toml $(HOME)/.config/starship.toml
	@[[ -f $(HOME)/.config/yamllint/config ]] \
		|| ln -sf $(PWD)/.yamllint $(HOME)/.config/yamllint/config
	@[[ -d $(HOME)/.vim/after ]] \
		|| ln -sf $(PWD)/.vim/after $(HOME)/.vim/after
	@[[ -d $(HOME)/.vim/syntax ]] \
		|| ln -sf $(PWD)/.vim/syntax $(HOME)/.vim/syntax
	@[[ -d $(HOME)/.config/nvim ]] \
		|| ln -sf $(PWD)/.nvim $(HOME)/.config/nvim
	@make \
		install-prezto \
		install-tpm \
		install-plug \
		install-zsh-completions
	@[[ -f $(HOME)/.tmux/scripts/clean ]] || { \
		mkdir -p $(HOME)/.tmux/scripts && \
			touch $(HOME)/.tmux/scripts/clean && \
			chmod 755 $(HOME)/.tmux/scripts/clean; \
	}

install-gems: ## Install gems, used for testing env
	$(info --> run `bundle install`)
	@gem install bundler --quiet
	@bundle install

install-pip-packages: ## Install python requirements, used for testing code
	$(MAKE) venv
	$(info --> Install ansible via `pip`)
	@( \
		source $(VIRTUALENV_DIR)/bin/activate; \
		pip install --upgrade setuptools; \
		pip install -r requirements.txt; \
	)

install-prezto: ## Install prezto, the confuguration framework for Zsh
	$(info --> Install Prezto)
	@[[ -d $(PREZTO) ]] \
		|| git clone -q --depth 1 --recursive \
		https://github.com/sorin-ionescu/prezto.git $(PREZTO)

install-tpm: ## Install tpm, the tmux plugin manager
	$(info --> Install tpm)
	@mkdir -p $(HOME)/.tmux/plugins
	@[[ -d $(HOME)/.tmux/plugins/tpm ]] \
		|| git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm

install-plug:  ## Install plug, the minimal plug-in manager for Vim
	$(info --> Install Plug)
	@curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	@vim +:PlugInstall +qall
	@vim +GoInstallBinaries +qall
	@mkdir -p $(HOME)/.vim/undofiles
	@[[ -f $(HOME)/.vim/plugged/lightline.vim/autoload/lightline/colorscheme/patatetoy.vim ]] \
		|| cp -f $(HOME)/.vim/plugged/vim-patatetoy/lightline/patatetoy.vim \
					$(HOME)/.vim/plugged/lightline.vim/autoload/lightline/colorscheme/patatetoy.vim

install-zsh-completions: ## Install some zsh completion files
	@mkdir -p $(HOME)/.zsh/completion
	@curl -Lso $(HOME)/.zsh/completion/_docker \
		  https://raw.github.com/felixr/docker-zsh-completion/master/_docker
	@mkdir -p $(HOME)/.travis
	@curl -Lso $(HOME)/.zsh/completion/travis.sh \
		https://raw.githubusercontent.com/travis-ci/travis.rb/master/assets/travis.sh

outdated-pip-packages: ## List outdated pip packages
	$(info --> List outdated packages)
	$(MAKE) venv
	@( \
		source $(VIRTUALENV_DIR)/bin/activate; \
		piprot requirements.txt; \
	)

pre-commit: ## Run pre-commit hooks
	$(info --> Run precommit hooks)
	$(MAKE) venv
	@( \
		source $(VIRTUALENV_DIR)/bin/activate; \
		pre-commit run --all; \
	)

setup-macos: ## Run macos script
	@bash -x ./.macos

setup-macos-hardening: ## Run macos_hardening script
	@bash -x ./.macos_hardening

shellcheck: ## Run shellcheck
	$(info --> Run shellcheck)
	@find install -type f -not -path '*etc*' -not -path '*fzf*' \
		| xargs -P 4 -I % shellcheck %
	@find . -type f -path '*sshrc*' -not -path '*tmux*' -not -path '*patatetoy*' \
		| xargs -P 4 -I % shellcheck %

test: ## Run shellcheck and pre-commit hooks
	$(MAKE) \
		shellcheck \
		pre-commit

venv: ## Create python virtualenv
		[[ -d $(VIRTUALENV_DIR) ]] || virtualenv -p $(shell command -v python3) $(VIRTUALENV_DIR)
