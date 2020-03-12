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
  fnm
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
  packer
  pandoc
  pgcli
  pyenv
  pyenv-virtualenv
  pyenv-virtualenvwrapper
  pv
  qemu
  ruby-install
  s3cmd
  shellcheck
  skopeo
  shfmt
  tag
  tig
  tcpdump
  tcptraceroute
  terraform
  terraform-inventory
  yamllint
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

describe command('~/.pyenv/shims/python --version') do
  its(:stdout) { should match /Python 3.8/ }
end

describe command('~/.rubies/ruby-2.6.5/bin/ruby --version') do
  its(:stdout) { should match /ruby 2.6.5/ }
end

describe command('node --version') do
  its(:stdout) { should match /v12.13.1/ }
end

describe command('eslint --version') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /v6/ }
end

describe command('prettier --version') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /1./ }
end

describe command('jsonlint --version') do
  its(:stdout) { should match /1./ }
end
