SHELL := /usr/bin/env bash
PREZTO := ~/.zprezto
PATATETOY := ~/.patatetoy
.DEFAULT_GOAL := help

help:
	@grep -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

install-packages: ## Install packages I love
	./install.sh

install-dotfiles: ## Install my dotfiles, included patatetoy prompt
	$(info --> Install dotfiles)
	@[[ -d $(PATATETOY) ]] \
		|| git clone https://github.com/loliee/patatetoy.git $(PATATETOY)
	@which stow >/dev/null || { echo'CAN I HAZ STOW ?'; exit 1; }
	@stow -S . -t "$(HOME)" -v \
		--ignore='.DS_Store' \
		--ignore='.fzf_history' \
		--ignore='.git' \
		--ignore='.travis.yml' \
		--ignore='install' \
		--ignore='install.sh' \
		--ignore='README.md' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='Rakefile' \
		--ignore='spec'
	make install-prezto
	make install-tpm
	make install-vundle

setup-iterm2: ## Configure iterm2 with patatetoy theme and great shortcut keys
	$(info --> Install iterm2)
	@[[ -L $(HOME)/.iterm2 ]] \
		|| ln -sf $(PWD)/.iterm2 $(HOME)/.iterm2
	@[[ -d $(HOME)/.iterm2/iterm2-patatetoy ]] \
		|| git clone https://github.com/loliee/iterm2-patatetoy/ $(HOME)/.iterm2/iterm2-patatetoy
	@open $(HOME)/.iterm2/iterm2-patatetoy/patatetoy.itermcolors
	@defaults read $(HOME)/.iterm2/com.googlecode.iterm2 &>/dev/null

install-tpm: ## Install tpm, the tmux plugin manager
	$(info --> Install tpm)
	@mkdir -p $(HOME)/.tmux/plugins
	@[[ -d $(HOME)/.tmux/plugins/tpm ]] \
		|| git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm

install-prezto: ## Install prezto, the confuguration framework for Zsh
	$(info --> Install Prezto)
	@[[ -d $(PREZTO) ]] \
		|| git clone -q --depth 1 --recursive \
		https://github.com/zsh-users/prezto.git $(PREZTO)
	@curl -fLo $(HOME)/.zprezto/modules/completion/external/src/_docker \
		  https://raw.github.com/felixr/docker-zsh-completion/master/_docker
	@curl -L https://raw.githubusercontent.com/docker/compose/$(shell docker-compose version --short)/contrib/completion/zsh/_docker-compose \
		> $(HOME)/.zprezto/modules/completion/external/src/_docker-compose

install-vundle:  ## Install vundle, the plug-in manager for Vim
	$(info --> Install Vundle)
	@mkdir -p $(HOME)/.vim/bundle/
	@[[ -d $(HOME)/.vim/bundle/Vundle.vim ]] \
		|| git clone https://github.com/gmarik/Vundle.vim.git $(HOME)/.vim/bundle/Vundle.vim
	@vim +PluginInstall +qall &>/dev/null
	@mkdir -p $(HOME)/.vim/undofiles
	@[[ -f $(HOME)/.vim/bundle/vim-airline/autoload/airline/themes/patatetoy.vim ]] \
		|| cp -f $(HOME)/.vim/bundle/vim-patatetoy/airline/patatetoy.vim $(HOME)/.vim/bundle/vim-airline/autoload/airline/themes/

uninstall: ## Uninstall dotfiles, Tmux Tpm, Prezto, Vundle
	@make uninstall-dotfiles \

uninstall-dotfiles: ## Uninstall dotfiles and patatetoy prompt
	$(info --> Uninstall dotfiles)
	@rm -rf $(HOME)/.patatetoy
	@stow -D . -t "$(HOME)" -v \
		--ignore='.DS_Store' \
		--ignore='.fzf_history' \
		--ignore='.git' \
		--ignore='.travis.yml' \
		--ignore='install' \
		--ignore='install.sh' \
		--ignore='README.md' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='Rakefile' \
		--ignore='spec'

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

shellcheck: ## Run shellcheck
	$(info --> Run shellcheck)
	@shellcheck --exclude=SC2148 .aliases .aliases.dev .aliases.osx
	@find . -name '*.sh'  | xargs -P 4 -I % shellcheck %

serverspec: ## Run serverspec
	$(info --> Run serverspec)
	@env \
		SPEC_OPTS='--format documentation --color' \
		rake serverspec:run

test: ## Run shellcheck and serverspec
	$(info --> Run serverspec)
	@make -j -l 2 shellcheck serverspec
