DOTFILES_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OS = $(shell uname)
SHELL := /usr/bin/env bash
PATH := $(HOME)/.local/share/mise/shims:/opt/homebrew/bin/:$(PATH)

.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.ONESHELL:
.PHONY: install test
.SHELLFLAGS := -eu -o pipefail -c

help:
	@grep -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

install: install-brew install-dotfiles install-git-hooks ## Full install

install-brew: # Install brew and packages
	./.brew

install-dotfiles: stow install-mise install-krew install-tpm ## Install my dotfiles
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
		--ignore='.github' \
		--ignore='.gnupg' \
		--ignore='.gemrc' \
		--ignore='.krew' \
		--ignore='^\.macos$$' \
		--ignore='.macos_hardening' \
		--ignore='.mdlrc' \
		--ignore='.mdl_style.rb' \
		--ignore='.pre-commit-config.yaml' \
		--ignore='.ssh' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='mise.toml' \
		--ignore='^mise\.lock$$' \
		--ignore='README.md'

install-mise: install-mise-global install-mise-repo ## Install the tools pinned by mise, global and repo

install-mise-global: ## Install the tools pinned in mise's global config
	$(info --> Install mise global tools)
	mise -C $(HOME) install

# The repo targets read mise.toml only, as CI does
install-mise-repo: export MISE_OVERRIDE_CONFIG_FILENAMES := mise.toml
install-mise-repo: ## Install the tools pinned in this repo's mise.toml
	$(info --> Install mise repo tools)
# In this repo mise also reads .config/mise/config.toml as a project config, and paranoid mode wants it trusted
	mise trust $(DOTFILES_DIR)/.config/mise/config.toml
	mise trust $(DOTFILES_DIR)/mise.toml
	mise install

install-krew: ## Install krew plugins, the kubectl plugin manager
	$(info --> Install krew)
	krew install < .krew

install-tpm: ## Install tpm, the tmux plugin manager
	$(info --> Install tpm)
	mkdir -p $(HOME)/.tmux/plugins
	[[ -d $(HOME)/.tmux/plugins/tpm ]] \
		|| git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm

install-git-hooks: ## Install git hooks
	prek install -f

setup-macos: ## Run macos script
	@bash -x ./.macos

setup-macos-hardening: ## Run macos_hardening script
	@bash -x ./.macos_hardening
