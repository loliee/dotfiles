require 'spec_helper'

def brew_prefix
   command('brew --prefix | tr -d "\n"').stdout
end

describe package('dnscrypt-proxy') do
  it { should be_installed }
end

describe command('brew services list') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should include('dnscrypt-proxy started') }
end

describe file("#{brew_prefix}/etc/dnscrypt-proxy.toml") do
  it { should be_file }
  its(:content) { should match /blacklist_file(\s)+(.*)dnscrypt-proxy-blacklist.txt/ }
  its(:content) { should match /listen_addresses = \['127.0.0.1:53'\]/ }
end

describe command('dig wikipedia.org @127.0.0.1') do
  its(:stdout) { should match /^wikipedia.org.(\s)+(\d)+(\s)+IN(\s)+A.*$/ }
end
