require 'spec_helper'

describe file("#{ENV['HOME']}/.gitconfig") do
  it { should be_file }
  it { should contain('name = Maxime Loliée') }
  it { should contain('email = maxime@siliadev.com') }
  it { should contain('ui = true') }
  it { should contain('signingkey = A477DCEB') }
  it { should contain('excludesfile = ~/.gitignore-global') }
  it { should contain('diff = diff-so-fancy | less --tabs=4 -RFX') }
  it { should contain('show = diff-so-fancy | less --tabs=4 -RFX') }
  it { should contain('whitespace = fix') }
  it { should contain('template = ~/.gitmessage') }
  it { should contain('autosquash = true') }
  it { should contain('gpgsign = true') }
  it { should contain('tool = vimdiff') }
end

describe file("#{ENV['HOME']}/.gitignore-global") do
  it { should be_file }
  it { should contain('id_rsa') }
  it { should contain('.fzf_history') }
end

describe file("#{ENV['HOME']}/.gitmessage") do
  it { should be_file }
  it { should contain('feat') }
  it { should contain('fix') }
  it { should contain('docs') }
  it { should contain('style') }
  it { should contain('refactor') }
  it { should contain('perf') }
  it { should contain('chore') }
  it { should contain('test') }
end

describe file("#{ENV['HOME']}/.tigrc") do
  it { should be_file }
  it { should contain("set main-view = line-number:no,interval=5 id:yes date:default author:full commit-title:yes,graph,refs,overflow=no") }
end
