require 'spec_helper'

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
    w0rp/ale
    mv/mv-vim-nginx
    ntpeters/vim-better-whitespace
    SirVer/ultisnips
    loliee/vim-patatetoy
    loliee/vim-snippets
    StanAngeloff/php.vim
    othree/html5.vim
  ).each do |p|
      it { should contain("Plugin '#{p}'") }
  end
end

describe file("#{ENV['HOME']}/.vimrc.min") do
  it { should be_file }
end
