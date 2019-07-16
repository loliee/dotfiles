require 'spec_helper'

describe file("#{ENV['HOME']}/.vimrc") do
  it { should be_file }
  it { should contain('set nocompatible') }
  it { should contain('set rtp+=~/.vim/bundle/Vundle.vim') }
  it { should contain('source ~/.vimrc.min') }
  %w(
    gmarik/Vundle.vim
    Glench/Vim-Jinja2-Syntax
    SirVer/ultisnips
    StanAngeloff/php.vim
    Yggdroot/indentLine
    airblade/vim-gitgutter
    editorconfig/editorconfig-vim
    ekalinin/Dockerfile.vim
    fatih/vim-go
    hashivim/vim-hashicorp-tools
    itchyny/lightline.vim
    junegunn/fzf
    junegunn/goyo.vim
    loliee/vim-patatetoy
    loliee/vim-snippets
    markcornick/vim-bats
    mileszs/ack.vim
    mv/mv-vim-nginx
    othree/html5.vim
    python-mode/python-mode
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
      it { should contain("Plugin '#{p}'") }
  end
end

describe file("#{ENV['HOME']}/.vimrc.min") do
  it { should be_file }
end
