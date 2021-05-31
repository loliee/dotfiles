require 'spec_helper'

# macOS specific
if os[:family] == 'darwin'

  %w(
    mattermost
    signal
    slack
  ).each do |p|
    describe command("brew info #{p}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should_not match /Not installed/ }
    end
  end
end
