DOTFILES_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OS = $(shell uname)
SHELL := /usr/bin/env bash
PATH := $(HOME)/.homebrew/bin/:$(PATH)

.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.ONESHELL:
.PHONY: install test
.SHELLFLAGS := -eu -o pipefail -c

help:
	@grep -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

install: install-brew install-dotfiles ## Full install

install-brew: # Install brew and packages
	./.brew

install-dotfiles: stow setup-vim install-krew install-tpm ## Install my dotfiles
	ln -sf $(PWD)/.gnupg/gpg.conf $(HOME)/.gnupg/gpg.conf
	[[ -f $(HOME)/.ssh/config ]] || cp $(DOTFILES_DIR)/.ssh/config $(HOME)/.ssh/

stow: ## Stow dotfiles
	$(info --> Install dotfiles)
	command -v stow >/dev/null || { echo'CAN I HAZ STOW ?'; exit 1; }
	stow -S . -t "$(HOME)" -v \
		--ignore='.DS_Store' \
		--ignore='.brew' \
		--ignore='.fzf_history' \
		--ignore='.git' \
		--ignore='.gnupg' \
		--ignore='.gemrc' \
		--ignore='.krew' \
		--ignore='.macos' \
		--ignore='.macos_hardening' \
		--ignore='.pre-commit-config.yaml' \
		--ignore='.ssh' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='README.md'

install-krew: ## Install krew plugins, the kubectl plugin manager
	$(info --> Install krew)
	kubectl krew install < .krew

install-tpm: ## Install tpm, the tmux plugin manager
	$(info --> Install tpm)
	mkdir -p $(HOME)/.tmux/plugins
	[[ -d $(HOME)/.tmux/plugins/tpm ]] \
		|| git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm

setup-vim:  ## Setup vim/neovim
	$(info --> Install Plug)
	[[ -f $(HOME)/.vim/autoload/plug.vim ]] || \
		curl -fLo $(HOME)/.vim/autoload/plug.vim --create-dirs \
			https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	vim +:PlugInstall +qall
	vim +GoInstallBinaries +qall
	mkdir -p $(HOME)/.vim/undofiles
	[[ -f $(HOME)/.vim/plugged/lightline.vim/autoload/lightline/colorscheme/patatetoy.vim ]] \
		|| cp -f $(HOME)/.vim/plugged/vim-patatetoy/lightline/patatetoy.vim \
			$(HOME)/.vim/plugged/lightline.vim/autoload/lightline/colorscheme/patatetoy.vim
	[[ -d $(HOME)/.config/nvim/pack/github/start/copilot.vim ]] \
		|| git clone https://github.com/github/copilot.vim \
			 $(HOME)/.config/nvim/pack/github/start/copilot.vim

setup-macos: ## Run macos script
	@bash -x ./.macos

setup-macos-hardening: ## Run macos_hardening script
	@bash -x ./.macos_hardening
