require 'spec_helper'

%w(
  stow
  macvim
).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end
