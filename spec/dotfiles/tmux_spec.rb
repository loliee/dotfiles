require 'spec_helper'

describe file("#{ENV['HOME']}/.tmux.conf") do
  it { should be_file }
  it { should contain('setw -g mode-keys vi') }
  it { should contain('set -g prefix C-a') }
  it { should contain('set -g mouse off') }
  it { should contain('bind | split-window -h') }
  it { should contain('bind - split-window -v') }
  it { should contain('unbind %') }
end
