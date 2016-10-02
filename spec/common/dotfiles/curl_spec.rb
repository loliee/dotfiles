require 'spec_helper'

describe file("#{ENV['HOME']}/.curlrc") do
  it { should be_file }
end
