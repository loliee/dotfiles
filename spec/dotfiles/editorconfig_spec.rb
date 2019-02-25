require 'spec_helper'

describe file("#{ENV['HOME']}/.editorconfig") do
  it { should be_file }
end
