SHELL := /usr/bin/env bash
PREZTO := ~/.zprezto
MLPURE := ~/.mlpure

install: install-dotfiles \
	install-tpm \
	install-prezto \
	install-vundle \
	install-tmuxline

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
	@ mkdir -p "$(HOME)/.ssh/tmp" && mkdir -p "$(HOME)/.ssh/assh.d"
	@ln -sf "$(PWD)/.assh"  "$(HOME)/.ssh/assh.yml"
	@stow -S . -t "$(HOME)" -v \
		--ignore='README.md' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='.media' \
		--ignore='.install.d' \
		--ignore='.DS_Store'
		--ignore='.assh'

uninstall-dotfiles:
	$(info --> Uninstall dotfiles)
	@rm -rf ~/.mlpure
	@stow -D . -t "$(HOME)" -v \
		--ignore='README.md' \
		--ignore='LICENCE' \
		--ignore='Makefile' \
		--ignore='.install.d' \
		--ignore='.DS_Store'
		--ignore='.assh'

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
	@mkdir -p ~/.vim/undofiles
	@ln -sf $(PWD)/.vim-snippets  ~/.vim/UltiSnips

uninstall-vundle:
	$(info --> Uninstall vundle)
	@[[ -d ~/.vim/bundle/Vundle.vim ]] \
		&& rm -rf ~/.vim/bundle/Vundle.vim

install-tmuxline: install-vundle
	$(info --> Create tmuxline snapshot)
	@vim +Tmuxline +"TmuxlineSnapshot! ~/.tmuxline.conf" +qall &> /dev/null

uninstall: uninstall_dotfiles

install-iterm2:
	$(info --> Install iterm2)
	@ln -sf "$(PWD)/.iterm2" ~/.iterm2
	@[[ -d ~/.iterm2/patatetoy-iterm2 ]] \
		|| git clone https://github.com/loliee/patatetoy-iterm2/ ~/.iterm2/patatetoy-iterm2
	@open ~/.iterm2/patatetoy-iterm2/patatetoy.itermcolors
	@defaults read ~/.iterm2/com.googlecode.iterm2 &>/dev/null

uninstall-iterm2:
	$(info --> Uninstall iterm2)
	@[[ -d ~/.patatetoy-iterm2 ]] \
		&& rm -rf ~/.iterm2/
