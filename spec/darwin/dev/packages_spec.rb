require 'spec_helper'

casks_list= %x( brew cask list )

%w(
 1password
 charles
 google-cloud-sdk
 docker
 little-snitch
 micro-snitch
 vagrant
 virtualbox
).each do |p|
  describe command("echo '#{casks_list}' | grep #{p}") do
    its(:exit_status) { should eq 0 }
  end
end

%w(
 bats
 bfg
 chruby
 cloc
 closure-compiler
 ctags
 diff-so-fancy
 entr
 gawk
 go
 hub
 kubernetes-helm
 ipcalc
 hadolint
 jq
 libxml2
 nmap
 packer
 pandoc
 pgcli
 pre-commit
 pyenv
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
