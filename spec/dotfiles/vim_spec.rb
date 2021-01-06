require 'spec_helper'

describe file("#{ENV['HOME']}/.vimrc") do
  it { should be_file }
  it { should contain('set nocompatible') }
  it { should contain('call plug#begin(\'~/.vim/plugged\')') }
  it { should contain('source ~/.vimrc.min') }
  %w(
    Glench/Vim-Jinja2-Syntax
    SirVer/ultisnips
    StanAngeloff/php.vim
    airblade/vim-gitgutter
    editorconfig/editorconfig-vim
    ekalinin/Dockerfile.vim
    fatih/vim-go
    hashivim/vim-hashicorp-tools
    itchyny/lightline.vim
    junegunn/fzf
    junegunn/fzf.vim
    junegunn/goyo.vim
    loliee/vim-patatetoy
    loliee/vim-snippets
    markcornick/vim-bats
    mv/mv-vim-nginx
    othree/html5.vim
    stephpy/vim-yaml
    tommcdo/vim-exchange
    tpope/vim-commentary
    tpope/vim-fugitive
    tpope/vim-liquid
    tpope/vim-markdown
    tpope/vim-repeat
    tpope/vim-surround
    vim-ruby/vim-ruby
    w0rp/ale
  ).each do |p|
      it { should contain("Plug '#{p}'") }
  end
end

describe file("#{ENV['HOME']}/.vimrc.min") do
  it { should be_file }
end
