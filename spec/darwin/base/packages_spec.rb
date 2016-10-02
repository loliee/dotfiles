require 'spec_helper'

casks_list= %x( brew cask list )

%w(
  google-chrome
  google-drive
  istat-menus
  iterm2
  java
  keepassx
  osxfuse
  xquartz
).each do |p|
  describe command("echo '#{casks_list}' | grep #{p}") do
    its(:exit_status) { should eq 0 }
  end
end

%w(
  openssl
  advancecomp
  ansifilter
  autoenv
  bindfs
  coreutils
  curl
  dnscrypt-proxy
  dnsmasq
  fasd
  findutils
  fzf
  git
  gsl
  htop-osx
  keybase
  libxml2
  moreutils
  ncdu
  ntfs-3g
  openssh
  pigz
  polipo
  pwgen
  readline
  reattach-to-user-namespace
  ssh-copy-id
  sshrc
  stow
  tag
  terminal-notifier
  tmux
  the_silver_searcher
  tldr
  tmux-cssh
  tmux-mem-cpu-load
  tree
  vim
  watch
  wget
  xz
  zopfli
  zsh-syntax-highlighting
  zsh
).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end
