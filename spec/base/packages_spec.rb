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
  gsl
  libxml2
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

  casks_list= %x( brew cask list )

  %w(
    google-chrome
    istat-menus
    iterm2
    java
    keepassx
    xquartz
  ).each do |p|
    describe command("echo '#{casks_list}' | grep #{p}") do
      its(:exit_status) { should eq 0 }
    end
  end
end
