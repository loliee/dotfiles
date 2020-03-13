require 'spec_helper'

describe file("#{ENV['HOME']}/.gitconfig") do
  it { should be_file }
  it { should contain('name = Maxime Loliée') }
  it { should contain('email = maxime@siliadev.com') }
  it { should contain('ui = true') }
  it { should contain('signingkey = 1B5A0D7E') }
  it { should contain('excludesfile = ~/.gitignore-global') }
  it { should contain('diff = diff-so-fancy | less --tabs=4 -RFX') }
  it { should contain('show = diff-so-fancy | less --tabs=4 -RFX') }
  it { should contain('whitespace = fix') }
  it { should contain('template = ~/.gitmessage') }
  it { should contain('autosquash = true') }
  it { should contain('gpgsign = true') }
  it { should contain('tool = vimdiff') }
  it { should contain('followTags = true') }
  it { should contain('rebase = true') }
end

describe file("#{ENV['HOME']}/.gitignore-global") do
  it { should be_file }
  it { should contain('id_rsa') }
  it { should contain('.fzf_history') }
end

describe file("#{ENV['HOME']}/.gitmessage") do
  it { should be_file }
  it { should contain('<subject>') }
  it { should contain('<body>') }
  it { should contain('<footer>') }
end
