require 'spec_helper'

describe file("#{ENV['HOME']}/.sshrc") do
  it { should be_file }
  it { should contain('TMUXDIR=/tmp/.mloliee.tmux.nkCx') }
  it { should contain('. "$SSHHOME/.sshrc.d/.aliases"') }
  it { should contain('. "$SSHHOME/.sshrc.d/.bashrc"') }
  it { should contain('. "$SSHHOME/.patatetoy/patatetoy.sh"') }
end

describe file("#{ENV['HOME']}/.sshrc.d/.aliases") do
  it { should be_linked_to "../.aliases" }
end

describe file("#{ENV['HOME']}/.sshrc.d/.bashrc") do
  it { should be_linked_to "../.bashrc" }
end

describe file("#{ENV['HOME']}/.sshrc.d/.tmux.conf") do
  it { should be_file }
  it { not contain('set -g prefix C-a') }
  it { should contain('bind | split-window -h') }
  it { should contain('bind - split-window -v') }
  it { should contain('unbind %') }
end

describe file("#{ENV['HOME']}/.sshrc.d/.vimrc") do
  it { should be_linked_to "../.vimrc.min" }
end
