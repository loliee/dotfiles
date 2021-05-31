require 'spec_helper'

%w(
  advancecomp
  ansifilter
  bash
  coreutils
  curl
  dnscrypt-proxy
  fasd
  fd
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

# Package not detected rg binary so install is tested  via the following task
describe command("rg --version") do
  its(:exit_status) { should eq 0 }
end

# macOS specific
if os[:family] == 'darwin'

  %w(
    istat-menus
    iterm2
    java
    keepassx
    openssl
    the-unarchiver
    tunnelblick
    xquartz
  ).each do |p|
    describe command("brew info #{p}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should_not match /Not installed/ }
    end
  end
end
