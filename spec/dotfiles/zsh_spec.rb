require 'spec_helper'

describe file("#{ENV['HOME']}/.zsh/completion") do
  it { should be_directory }
end

describe file("#{ENV['HOME']}/.zsh/completion/_docker") do
  it { should be_file }
end

describe file("#{ENV['HOME']}/.zsh/completion/travis.sh") do
  it { should be_file }
end
