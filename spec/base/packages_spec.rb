require 'spec_helper'

%w(
  openssl
  advancecomp
  ansifilter
  autoenv
  bash
  coreutils
  curl
  dnscrypt-proxy
  fasd
  findutils
  fzf
  git
  gnu-sed
  gnu-tar
  gnu-time
  gnu-which
  grep
  gsl
  libxml2
  macvim
  moreutils
  ncdu
  openssh
  pigz
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
  tree
  tunnelblick
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

# macOS specific
if os[:family] == 'darwin'

  %w(
    google-chrome
    istat-menus
    iterm2
    java
    keepassx
    xquartz
  ).each do |p|
    describe command("brew cask info #{p}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should_not match /Not installed/ }
    end
  end
end
