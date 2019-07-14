require 'spec_helper'

%w(
  asciinema
  direnv
  bats
  bfg
  chruby
  cloc
  closure-compiler
  ctags
  diff-so-fancy
  dive
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
  mkcert
  mtr
  nmap
  nvm
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
    firefox
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

describe command('python --version') do
  its(:stdout) { should match /Python 3.7/ }
end

describe command('ruby --version') do
  its(:stdout) { should match /ruby 2.6.3/ }
end

describe command('node --version') do
  its(:stdout) { should match /v10.16.0/ }
end

describe command('command -v node') do
  its(:stdout) { should match /.nvm\/versions\/node\/v10.16.0/ }
end
