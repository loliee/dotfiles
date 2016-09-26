require 'spec_helper'

describe file("#{ENV['HOME']}/.aliases") do
  it { should be_file }
  it { should contain('function rmf') }
  it { should contain('function ssht') }
  it { should contain('alias j') }
  it { should contain("alias ll='ls -lah'") }
  it { should contain("alias rm='rm -i --preserve-root'") }
end

describe file("#{ENV['HOME']}/.aliases.dev") do
  it { should be_file }
end

describe file("#{ENV['HOME']}/.aliases.osx") do
  it { should be_file }
end

describe file("#{ENV['HOME']}/.bashrc") do
  it { should be_file }
  it { should contain('set -o vi') }
  it { should contain('export LANGUAGE="en_US.UTF-8"') }
  it { should contain('export VISUAL=vim') }
  it { should contain('export EDITOR="${VISUAL}"') }
  it { should contain('. "${HOME}/.patatetoy/patatetoy.sh"') }
  it { should contain('. "${HOME}/.aliases"') }
  it { should contain('. /etc/bash_completion') }
end

describe file("#{ENV['HOME']}/.curlrc") do
  it { should be_file }
end

describe file("#{ENV['HOME']}/.editorconfig") do
  it { should be_file }
end

describe file("#{ENV['HOME']}/.gitconfig") do
  it { should be_file }
  it { should contain('name = Maxime Loliée') }
  it { should contain('email = maxime@siliadev.com') }
  it { should contain('ui = true') }
  it { should contain('signingkey = FC6E9816') }
  it { should contain('excludesfile = ~/.gitignore-global') }
  it { should contain('diff = diff-so-fancy | less --tabs=4 -RFX') }
  it { should contain('show = diff-so-fancy | less --tabs=4 -RFX') }
  it { should contain('whitespace = fix') }
  it { should contain('template = ~/.gitmessage') }
  it { should contain('autosquash = true') }
  it { should contain('gpgsign = true') }
  it { should contain('tool = vimdiff') }
end

describe file("#{ENV['HOME']}/.gitignore-global") do
  it { should be_file }
  it { should contain('id_rsa') }
  it { should contain('.fzf_history') }
end

describe file("#{ENV['HOME']}/.gitmessage") do
  it { should be_file }
  it { should contain('feat') }
  it { should contain('fix') }
  it { should contain('docs') }
  it { should contain('style') }
  it { should contain('refactor') }
  it { should contain('perf') }
  it { should contain('chore') }
  it { should contain('test') }
end

describe file("#{ENV['HOME']}/.hushlogin") do
  it { should be_file }
end

describe file("#{ENV['HOME']}/.sshrc") do
  it { should be_file }
  it { should contain('TMUXDIR=/tmp/.mloliee.tmux.nkCx') }
  it { should contain('. "$SSHHOME/.sshrc.d/.aliases"') }
  it { should contain('. "$SSHHOME/.sshrc.d/.bashrc"') }
  it { should contain('. "$SSHHOME/.patatetoy/patatetoy.sh"') }
end

describe file("#{ENV['HOME']}/.sshrc.d/.aliases") do
  it { should be_linked_to "../.aliases" }
end

describe file("#{ENV['HOME']}/.sshrc.d/.bashrc") do
  it { should be_linked_to "../.bashrc" }
end

describe file("#{ENV['HOME']}/.sshrc.d/.tmux.conf") do
  it { should be_file }
  it { not contain('set -g prefix C-a') }
  it { should contain('bind | split-window -h') }
  it { should contain('bind - split-window -v') }
  it { should contain('unbind %') }
end

describe file("#{ENV['HOME']}/.sshrc.d/.vimrc") do
  it { should be_linked_to "../.vimrc.min" }
end

describe file("#{ENV['HOME']}/.tigrc") do
  it { should be_file }
  it { should contain("set main-view = line-number:no,interval=5 id:yes date:default author:full commit-title:yes,graph,refs,overflow=no") }
end

describe file("#{ENV['HOME']}/.tmux.conf") do
  it { should be_file }
  it { should contain('setw -g mode-keys vi') }
  it { should contain('set -g prefix C-a') }
  it { should contain('set -g mouse off') }
  it { should contain('bind | split-window -h') }
  it { should contain('bind - split-window -v') }
  it { should contain('unbind %') }
end

describe file("#{ENV['HOME']}/.vimrc") do
  it { should be_file }
  it { should contain('set nocompatible') }
  it { should contain('set rtp+=~/.vim/bundle/Vundle.vim') }
  it { should contain('source ~/.vimrc.min') }
  %w(
    rking/ag.vim
    markcornick/vim-bats
    ekalinin/Dockerfile.vim
    vim-airline/vim-airline
    editorconfig/editorconfig-vim
    tommcdo/vim-exchange
    tpope/vim-fugitive
    airblade/vim-gitgutter
    junegunn/fzf
    junegunn/goyo.vim
    fatih/vim-go
    tpope/vim-markdown
    tpope/vim-surround
    tpope/vim-repeat
    scrooloose/syntastic
    mv/mv-vim-nginx
    ntpeters/vim-better-whitespace
    SirVer/ultisnips
    loliee/vim-patatetoy
    loliee/vim-snippets
    terryma/vim-multiple-cursors
    StanAngeloff/php.vim
    othree/html5.vim
  ).each do |p|
      it { should contain("Plugin '#{p}'") }
  end
end

describe file("#{ENV['HOME']}/.vimrc.min") do
  it { should be_file }
end

describe file("#{ENV['HOME']}/.zshrc") do
  it { should be_file }
  it { should contain('source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"') }
  it { should contain("bindkey '^[[B' history-substring-search-down") }
  it { should contain("bindkey '^[[A' history-substring-search-up") }
end

describe file("#{ENV['HOME']}/.zshenv") do
  it { should be_file }
  it { should contain('source "${ZDOTDIR:-$HOME}/.zprofile"') }
  it { should contain('fpath=( "${ZDOTDIR:-$HOME}/.patatetoy/" $fpath )') }
end

describe file("#{ENV['HOME']}/.zlogin") do
  it { should be_file }
end

describe file("#{ENV['HOME']}/.zlogout") do
  it { should be_file }
end

describe file("#{ENV['HOME']}/.zprofile") do
  it { should be_file }
  it { should contain("export LANG='en_US.UTF-8'") }
  it { should contain("export LC_ALL='en_US.UTF-8'") }
  it { should contain("export EDITOR='vim'") }
  it { should contain("export VISUAL='vim'") }
  it { should contain("export HISTFILE=~/.zsh_history") }
  it { should contain("export PAGER='less'") }
  it { should contain("export LESS='-F -g -i -M -R -S -w -X -z-4'") }
  it { should contain("export HOMEBREW_CASK_OPTS='--appdir=/Applications  --caskroom=/usr/local/Caskroom'") }
  it { should contain("FZF_DEFAULT_COMMAND='ag -l -g") }
  it { should contain("export PATATETOY_VIM_MODE=1") }
  it { should contain('source "${HOMEBREW_ROOT}/opt/autoenv/activate.sh"') }
end

describe file("#{ENV['HOME']}/.zpreztorc") do
  it { should be_file }
  it { should contain("zstyle ':prezto:*:*' case-sensitive 'no'") }
  it { should contain("zstyle ':prezto:*:*' color 'yes'") }
  it { should contain("zstyle ':prezto:module:terminal' auto-title 'yes'") }
  it { should contain("zstyle ':prezto:module:prompt' theme 'patatetoy'") }
  it { should contain("zstyle ':prezto:module:editor' key-bindings 'vi'") }
  it { should contain("zstyle ':prezto:module:history-substring-search' case-sensitive 'yes'") }
  it { should contain("zstyle ':prezto:module:tmux:auto-start' local 'yes'") }
  it { should contain("zstyle ':prezto:module:tmux:auto-start' remote 'yes'") }
  it { should contain("zstyle ':prezto:module:tmux:auto-start' remote 'yes'") }
  it { should contain("zstyle ':prezto:load' pmodule \
    'environment' \
    'terminal' \
    'editor' \
    'history' \
    'directory' \
    'spectrum' \
    'utility' \
    'ssh' \
    'completion' \
    'syntax-highlighting' \
    'history-substring-search' \
    'prompt' \
    'fasd' \
    'tmux'
  ") }
end
