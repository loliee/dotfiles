require 'spec_helper'

casks_list= %x( brew cask list )

%w(
  flux
  gimp
  google-chrome
  google-hangouts
  google-drive
  gpgtools
  imageoptim
  istat-menus
  iterm2
  java
  keepassx
  osxfuse
  skype
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
  bats
  bfg
  bindfs
  chruby
  cloc
  closure-compiler
  coreutils
  ctags
  curl
  diff-so-fancy
  dnscrypt-proxy
  dnsmasq
  fasd
  findutils
  fzf
  gifsicle
  git
  go
  graphviz
  gsl
  hadolint
  htmlcompressor
  htop-osx
  hub
  ipcalc
  jq
  imagemagick
  jhead
  jpeg
  jpegoptim
  keybase
  libxml2
  moreutils
  ncdu
  nmap
  optipng
  openssh
  packer
  pandoc
  pgcli
  pigz
  pngcrush
  pngquant
  polipo
  pre-commit
  pv
  pwgen
  python
  python3
  readline
  reattach-to-user-namespace
  ruby-install
  s3cmd
  shellcheck
  spark
  ssh-copy-id
  sshrc
  stow
  tag
  terminal-notifier
  tmux
  tcpdump
  tcptraceroute
  the_silver_searcher
  tig
  tldr
  tmux-cssh
  tmux-mem-cpu-load
  tree
  vim
  watch
  webkit2png
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

describe command('hash kubectl') do
    its(:exit_status) { should eq 0 }
end

describe command('node --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include('v6') }
end

describe command('pt --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include('pt version 2.1') }
end

describe command('svn --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include('svn, version 1.9') }
end

describe command('terraform --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include('Terraform v0.7') }
end
