require 'spec_helper'

describe file("#{ENV['HOME']}/.config/hadolint.yaml") do
  it { should be_file }
  it { should contain /DL3008/ }
end
