require 'spec_helper'

describe file("#{ENV['HOME']}/.bashrc") do
  it { should be_file }
  it { should contain('set -o vi') }
  it { should contain('export LANGUAGE="en_US.UTF-8"') }
  it { should contain('export VISUAL=vim') }
  it { should contain('export EDITOR="${VISUAL}"') }
  it { should contain('. "${HOME}/.patatetoy/patatetoy.sh"') }
  it { should contain('. "${HOME}/.aliases"') }
  it { should contain('. /etc/bash_completion') }
end

describe file("#{ENV['HOME']}/.hushlogin") do
  it { should be_file }
end
