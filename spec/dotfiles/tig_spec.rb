require 'spec_helper'

describe file("#{ENV['HOME']}/.tigrc") do
  it { should be_file }
  it { should contain("set main-view = line-number:no,interval=5 id:yes date:default author:full commit-title:yes,graph,refs,overflow=no") }
  it { should contain('set refresh-mode = after-command') }
  it { should contain('bind main F !git cf %(commit)') }
  it { should contain('bind main R !git ri %(commit)^') }
  it { should contain('bind main A !git a %(file)') }
  it { should contain('bind generic YI @sh -c "printf \'%s\' %(commit) | pbcopy"') }
  it { should contain('bind generic YM @sh -c "git rev-list --format=%B --max-count=1 %(commit) | sed \'1d\' | pbcopy"') }
end
