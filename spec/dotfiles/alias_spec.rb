require 'spec_helper'

describe file("#{ENV['HOME']}/.aliases") do
  it { should be_file }
  it { should contain('function rmf') }
  it { should contain('function ssht') }
  it { should contain('alias j') }
  it { should contain("alias ll='ls -lah'") }
  it { should contain("alias rm='rm -i --preserve-root'") }
end

describe file("#{ENV['HOME']}/.aliases.dev") do
  it { should be_file }
end

describe file("#{ENV['HOME']}/.aliases.osx") do
  it { should be_file }
end
