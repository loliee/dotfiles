require 'spec_helper'

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
  it { should contain("export HOMEBREW_CASK_OPTS='--appdir=/Applications'") }
  it { should contain("FZF_DEFAULT_COMMAND='ag -l -g") }
  it { should contain("export PATATETOY_VIM_MODE=1") }
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
