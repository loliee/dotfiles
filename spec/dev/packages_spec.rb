require 'spec_helper'

%w(
  bats
  bfg
  chruby
  cloc
  closure-compiler
  ctags
  diff-so-fancy
  entr
  kubectx
  kubernetes-cli
  kubernetes-helm
  go
  gawk
  hub
  ipcalc
  hadolint
  jq
  libxml2
  node
  nmap
  packer
  pandoc
  pgcli
  pre-commit
  pyenv
  pyenv-virtualenv
  pyenv-virtualenvwrapper
  pv
  qemu
  ruby-install
  s3cmd
  shellcheck
  spark
  tag
  tig
  tcpdump
  tcptraceroute
  terraform
  terraform-inventory
).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

# macOS specific
if os[:family] == 'darwin'

  %w(
    1password
    charles
    fly
    google-cloud-sdk
    docker
    little-snitch
    micro-snitch
    vagrant
    virtualbox
  ).each do |p|
    describe command("brew cask info #{p}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should_not match /Not installed/ }
    end
  end
end
