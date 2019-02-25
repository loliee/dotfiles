require 'spec_helper'

# macOS specific
if os[:family] == 'darwin'

  casks_list= %x( brew cask list )

  %w(
    google-hangouts
    hipchat
    skype
    slack
  ).each do |p|
    describe command("echo '#{casks_list}' | grep #{p}") do
      its(:exit_status) { should eq 0 }
    end
  end
end
