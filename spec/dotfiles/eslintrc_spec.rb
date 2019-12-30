require 'spec_helper'

describe file("#{ENV['HOME']}/.eslintrc") do
  it { should be_file }
  it { should contain('"ecmaVersion": 6') }
end
