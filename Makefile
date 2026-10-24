DOTFILES_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OS = $(shell uname)
SHELL := bash
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

install: brew-install dotfiles-install git-hooks-install ## Full install

test: ## Run the tests of the fish libs
	bats tests

brew-install: # Install brew and packages
	./.brew

dotfiles-install: stow mise-install krew-install tpm-install ## Install my dotfiles
	mkdir -p -m 700 $(HOME)/.gnupg $(HOME)/.ssh
	ln -sf $(PWD)/.gnupg/gpg.conf $(HOME)/.gnupg/gpg.conf
	ln -sf $(PWD)/.gnupg/gpg-agent.conf $(HOME)/.gnupg/gpg-agent.conf
	ln -sf $(PWD)/.gnupg/pinentry-op $(HOME)/.gnupg/pinentry-op
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
		--ignore='^\.coredns$$' \
		--ignore='^\.opx-net-down$$' \
		--ignore='.pre-commit-config.yaml' \
		--ignore='.ssh' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='mise.toml' \
		--ignore='^mise\.lock$$' \
		--ignore='^\.claude$$' \
		--ignore='README.md'

mise-install: mise-install-home mise-install-repo ## Install the tools pinned by mise, home and repo

mise-install-home: ## Install the tools pinned in mise's global config
	$(info --> Install mise home tools)
	$(RAISE_NOFILE) mise -C $(HOME) install

# The repo targets read mise.toml only, as CI does
mise-install-repo: export MISE_OVERRIDE_CONFIG_FILENAMES := mise.toml
mise-install-repo: ## Install the tools pinned in this repo's mise.toml
	$(info --> Install mise repo tools)
# In this repo mise also reads .config/mise/config.toml as a project config, and paranoid mode wants it trusted
	mise trust $(DOTFILES_DIR)/.config/mise/config.toml
	mise trust $(DOTFILES_DIR)/mise.toml
	$(RAISE_NOFILE) mise install

krew-install: ## Install krew plugins, the kubectl plugin manager
	$(info --> Install krew)
	krew install < .krew

tpm-install: ## Install tpm, the tmux plugin manager
	$(info --> Install tpm)
	mkdir -p $(HOME)/.tmux/plugins
	[[ -d $(HOME)/.tmux/plugins/tpm ]] \
		|| git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm

git-hooks-install: ## Install git hooks
	prek install -f

mise-outdated: mise-outdated-home mise-outdated-repo ## Show the newer releases of the mise tools, home and repo

mise-outdated-home: ## Show the newer releases of the home mise tools
	mise -C $(HOME) outdated --bump

mise-outdated-repo: export MISE_OVERRIDE_CONFIG_FILENAMES := mise.toml
mise-outdated-repo: ## Show the newer releases of this repo's mise tools
	mise outdated --bump --local

mise-upgrade: mise-upgrade-home mise-upgrade-repo ## Bump every mise tool, home and repo

mise-upgrade-home: ## Bump the home mise tools, or only TOOLS="a b", to releases older than 7 days
	$(RAISE_NOFILE) mise -C $(HOME) upgrade --bump --minimum-release-age 7d $(TOOLS)
	mise -C $(HOME) lock --global

mise-upgrade-repo: export MISE_OVERRIDE_CONFIG_FILENAMES := mise.toml
mise-upgrade-repo: ## Bump this repo's mise tools, or only TOOLS="a b", to releases older than 7 days
	$(RAISE_NOFILE) mise upgrade --bump --local --minimum-release-age 7d $(TOOLS)
	mise lock

mise-lock: mise-lock-home mise-lock-repo ## Lock the mise tools, home and repo

# From $(HOME): inside this repo, mise leaves the tools mise.toml also declares out of the global lock
mise-lock-home: ## Lock the home mise tools
	mise -C $(HOME) lock --global

mise-lock-repo: export MISE_OVERRIDE_CONFIG_FILENAMES := mise.toml
mise-lock-repo: ## Lock this repo's mise tools, for macOS and the Linux CI
	mise lock

actions-upgrade: ## Bump the GitHub Actions pinned by SHA to releases older than 7 days
	pinact run --update --min-age 7

macos-setup: ## Run macos script
	@bash -x ./.macos

macos-setup-hardening: ## Run macos_hardening script
	@bash -x ./.macos_hardening
