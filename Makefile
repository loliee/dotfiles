DOTFILES_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OS = $(shell uname)
SHELL := /usr/bin/env bash
PATH := $(HOME)/.local/share/mise/shims:/opt/homebrew/bin/:$(PATH)
# macOS starts shells at 256 open files, too few for parallel mise installs; the macOS make 3.81 runs each line in its own shell
RAISE_NOFILE := ulimit -S -n 10240 &&

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
	mkdir -p -m 700 $(HOME)/.gnupg $(HOME)/.ssh
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
		--ignore='^\.coredns\.plist$$' \
		--ignore='^\.opx-net-down$$' \
		--ignore='.pre-commit-config.yaml' \
		--ignore='.ssh' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='mise.toml' \
		--ignore='^mise\.lock$$' \
		--ignore='^\.claude$$' \
		--ignore='README.md'

install-mise: install-mise-global install-mise-repo ## Install the tools pinned by mise, global and repo

install-mise-global: ## Install the tools pinned in mise's global config
	$(info --> Install mise global tools)
	$(RAISE_NOFILE) mise -C $(HOME) install

# The repo targets read mise.toml only, as CI does
install-mise-repo: export MISE_OVERRIDE_CONFIG_FILENAMES := mise.toml
install-mise-repo: ## Install the tools pinned in this repo's mise.toml
	$(info --> Install mise repo tools)
# In this repo mise also reads .config/mise/config.toml as a project config, and paranoid mode wants it trusted
	mise trust $(DOTFILES_DIR)/.config/mise/config.toml
	mise trust $(DOTFILES_DIR)/mise.toml
	$(RAISE_NOFILE) mise install

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

outdated-mise: outdated-mise-global outdated-mise-repo ## Show the newer releases of the mise tools, global and repo

outdated-mise-global: ## Show the newer releases of the global mise tools
	mise -C $(HOME) outdated --bump

outdated-mise-repo: export MISE_OVERRIDE_CONFIG_FILENAMES := mise.toml
outdated-mise-repo: ## Show the newer releases of this repo's mise tools
	mise outdated --bump --local

upgrade-mise: upgrade-mise-global upgrade-mise-repo ## Bump every mise tool, global and repo

upgrade-mise-global: ## Bump the global mise tools, or only TOOLS="a b", to releases older than 7 days
	$(RAISE_NOFILE) mise -C $(HOME) upgrade --bump --minimum-release-age 7d $(TOOLS)
	mise -C $(HOME) lock --global

upgrade-mise-repo: export MISE_OVERRIDE_CONFIG_FILENAMES := mise.toml
upgrade-mise-repo: ## Bump this repo's mise tools, or only TOOLS="a b", to releases older than 7 days
	$(RAISE_NOFILE) mise upgrade --bump --local --minimum-release-age 7d $(TOOLS)
	mise lock

lock-mise: lock-mise-global lock-mise-repo ## Lock the mise tools, global and repo

# From $(HOME): inside this repo, mise leaves the tools mise.toml also declares out of the global lock
lock-mise-global: ## Lock the global mise tools
	mise -C $(HOME) lock --global

lock-mise-repo: export MISE_OVERRIDE_CONFIG_FILENAMES := mise.toml
lock-mise-repo: ## Lock this repo's mise tools, for macOS and the Linux CI
	mise lock

upgrade-actions: ## Bump the GitHub Actions pinned by SHA to releases older than 7 days
	pinact run --update --min-age 7

setup-macos: ## Run macos script
	@bash -x ./.macos

setup-macos-hardening: ## Run macos_hardening script
	@bash -x ./.macos_hardening
