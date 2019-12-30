MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables
DOTFILES_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OS = $(shell uname)
PATATETOY := ~/.patatetoy
PREZTO := ~/.zprezto
RUN_LIST ?= base dev dotfiles messaging multimedia privacy
SHELL := /usr/bin/env bash
VIRTUALENV_DIR := $(DOTFILES_DIR)/venv

.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.ONESHELL:
.PHONY: install test
.SHELLFLAGS := -eu -o pipefail -c

help:
	@grep -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

install: ## Full install, var: RUN_LIST=base,dev,dotfiles,messaging,multimedia,privacy
	@if [[ "$(OS)" == "Darwin" ]]; then \
		make install-brew; \
		if [[ -d $(HOME)/Applications/iTerm.app && "$(RUN_LIST)" =~ dotfiles ]]; then \
			make setup-iterm2; \
		fi; \
	fi
	@if [[ "$(RUN_LIST)" =~ dotfiles ]]; then \
		make install-dotfiles; \
	fi

install-brew: # Install brew and packages
	@bash -x ./install/brew

install-dev: ## Install test environment
	@if [[ "$(OS)" == "Darwin" ]]; then \
		brew install shellcheck; \
	fi
	@$(MAKE) -j 2 \
		install-gems \
		install-pip-packages;

install-dotfiles: ## Install my dotfiles, included patatetoy prompt
	$(info --> Install dotfiles)
	@command -v stow >/dev/null || { echo'CAN I HAZ STOW ?'; exit 1; }
	@stow -S . -t "$(HOME)" -v \
		--ignore='.DS_Store' \
		--ignore='.fzf_history' \
		--ignore='.gemrc' \
		--ignore='.git' \
		--ignore='.hadolint.yml' \
		--ignore='.iterm2' \
		--ignore='.travis.yml' \
		--ignore='.vim' \
		--ignore='.yamllint' \
		--ignore='Gemfile' \
		--ignore='Gemfile.lock' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='README.md' \
		--ignore='Rakefile' \
		--ignore='install' \
		--ignore='spec' \
		--ignore='venv'
	@mkdir -p \
		$(HOME)/.vim \
		$(HOME)/.config/yamllint
	@[[ -d $(HOME)/.config ]] \
		|| mkdir $(HOME).config
	@[[ -f $(HOME)/.config/hadolint.yaml ]] \
		|| ln -sf $(PWD)/.hadolint.yml $(HOME)/.config/hadolint.yaml
	@[[ -f $(HOME)/.config/yamllint/config ]] \
		|| ln -sf $(PWD)/.yamllint $(HOME)/.config/yamllint/config
	@[[ -d $(PATATETOY) ]] \
		|| git clone https://github.com/loliee/prompt-patatetoy.git $(PATATETOY)
	@[[ -d $(HOME)/.sshrc.d/patatetoy_common.sh ]] \
		|| ln -sf $(PATATETOY)/patatetoy_common.sh $(HOME)/.sshrc.d/patatetoy_common.sh
	@[[ -d $(HOME)/.sshrc.d/patatetoy.sh ]] \
		|| ln -sf $(PATATETOY)/patatetoy.sh $(HOME)/.sshrc.d/patatetoy.sh
	@[[ -d $(HOME)/.vim/after ]] \
		|| ln -sf $(PWD)/.vim/after $(HOME)/.vim/after
	@[[ -d $(HOME)/.vim/syntax ]] \
		|| ln -sf $(PWD)/.vim/syntax $(HOME)/.vim/syntax
	@make \
		install-prezto \
		install-tpm \
		install-vundle \
		install-zsh-completions

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

install-vundle:  ## Install vundle, the plug-in manager for Vim
	$(info --> Install Vundle)
	@mkdir -p $(HOME)/.vim/bundle/
	@[[ -d $(HOME)/.vim/bundle/Vundle.vim ]] \
		|| git clone https://github.com/gmarik/Vundle.vim.git $(HOME)/.vim/bundle/Vundle.vim
	@vim +PluginInstall +qall
	@vim +GoInstallBinaries +qall
	@mkdir -p $(HOME)/.vim/undofiles
	@[[ -f $(HOME)/.vim/bundle/lightline.vim/autoload/lightline/colorscheme/patatetoy.vim ]] \
		|| cp -f $(HOME)/.vim/bundle/vim-patatetoy/lightline/patatetoy.vim \
					$(HOME)/.vim/bundle/lightline.vim/autoload/lightline/colorscheme/patatetoy.vim

install-zsh-completions: ## Install some zsh completion files
	@mkdir -p $(HOME)/.zsh/completion
	@curl -Lso $(HOME)/.zsh/completion/_docker \
		  https://raw.github.com/felixr/docker-zsh-completion/master/_docker
	@curl -Lso $(HOME)/.zsh/completion/_fly \
		https://raw.githubusercontent.com/sergiubodiu/fly-zsh-autocomplete-plugin/master/_fly
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

setup-iterm2: ## Configure iterm2 with patatetoy theme and great shortcut keys
	$(info --> Install iterm2)
	@[[ -L $(HOME)/.iterm2 ]] \
		|| ln -sf $(PWD)/.iterm2 $(HOME)/.iterm2
	@[[ -d $(HOME)/.iterm2/iterm2-patatetoy ]] \
		|| git clone https://github.com/loliee/iterm2-patatetoy/ $(HOME)/.iterm2/iterm2-patatetoy
	@open $(HOME)/.iterm2/iterm2-patatetoy/patatetoy.itermcolors
	@defaults read $(HOME)/.iterm2/com.googlecode.iterm2 &>/dev/null

setup-macos: ## Run macos script
	@bash -x ./install/macos

setup-macos-hardening: ## Run macos_hardening script
	@bash -x ./install/macos_hardening

serverspec: ## Run serverspec, var: RUN_LIST=base,dev,dotfiles,messaging,multimedia,privacy
	$(info --> Run serverspec)
	@env \
		SPEC_OPTS='--format documentation --color' \
		rake serverspec:run

shellcheck: ## Run shellcheck
	$(info --> Run shellcheck)
	@find install -type f -not -path '*etc*' -not -path '*fzf*' \
		| xargs -P 4 -I % shellcheck %
	@find . -type f -path '*sshrc*' -not -path '*tmux*' -not -path '*patatetoy*' \
		| xargs -P 4 -I % shellcheck %

test: ## Run shellcheck, serverspec and pre-commit hooks, var: RUN_LIST=base,dev,dotfiles,messaging,multimedia,privacy
	$(info --> Run serverspec)
	@make -j -l 3 shellcheck serverspec pre-commit

uninstall: ## Uninstall dotfiles, Tmux Tpm, Prezto, Vundle
	@make uninstall-dotfiles \

uninstall-brew: ## Uninstall brew and packages
	@curl -o /tmp/uninstall-brew.rb \
		-fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall \
		&& chmod u+x /tmp/uninstall-brew.rb \
		&& /tmp/uninstall-brew.rb
	@rm -f /tmp/uninstall-brew.rb

uninstall-dotfiles: ## Uninstall dotfiles and patatetoy prompt
	$(info --> Uninstall dotfiles)
	@rm -rf $(HOME)/.patatetoy
	@stow -D . -t "$(HOME)" -v \
		--ignore='.DS_Store' \
		--ignore='.fzf_history' \
		--ignore='.git' \
		--ignore='.hadolint.yml' \
		--ignore='.iterm2' \
		--ignore='.travis.yml' \
		--ignore='.vim' \
		--ignore='.yamllint' \
		--ignore='Gemfile' \
		--ignore='Gemfile.lock' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='README.md' \
		--ignore='Rakefile' \
		--ignore='gemrc' \
		--ignore='install' \
		--ignore='spec' \
		--ignore='venv'
	@rm -f $(HOME)/.config/hadolint.yaml

uninstall-tpm: ## Uninstall tmux plugin manager
	$(info --> Uninstall tpm)
	@[[ -d $(HOME)/.tmux/plugins/tpm ]] \
		&& rm -rf $(HOME)/.tmux/plugins/tmp

uninstall-prezto: ## Uninstall Prezto
	$(info --> Uninstall Prezto)
	@[[ -d $(PREZTO) ]] \
		&& rm -rf $(PREZTO)

uninstall-vundle: ## Uninstall Vundle
	$(info --> Uninstall vundle)
	@[[ -d $(HOME)/.vim/bundle ]] \
		&& rm -rf $(HOME)/.vim/bundle

venv: ## Create python virtualenv
		[[ -d $(VIRTUALENV_DIR) ]] || virtualenv -p $(shell command -v python3) $(VIRTUALENV_DIR)
