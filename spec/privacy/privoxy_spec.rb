require 'spec_helper'

def brew_prefix
   command('brew --prefix | tr -d "\n"').stdout
end

describe package('privoxy') do
  it { should be_installed }
end

describe command('brew services list') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should include('privoxy') }
end

describe file("#{brew_prefix}/etc/privoxy/config") do
  it { should be_file }
  its(:content) { should match /listen-address 127.0.0.1:8118/ }
end

describe port(8118) do
  it { should be_listening.on('127.0.0.1').with('tcp') }
end
