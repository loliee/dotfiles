require 'spec_helper'

describe file("#{ENV['HOME']}/.config/yamllint/config") do
  it { should be_file }
  it { should contain /max: 120/ }
  it { should contain /level: warning/ }
end
