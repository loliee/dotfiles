require 'spec_helper'

describe file("#{ENV['HOME']}/.patatetoy/prompt_patatetoy_setup") do
  it { should be_file }
  it { should contain /prompt_patatetoy_setup "\$@"/ }
end
