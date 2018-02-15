require 'spec_helper'

describe command('hash kubectl') do
    its(:exit_status) { should eq 0 }
end

describe command('node --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include('v9') }
end

describe command('svn --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include('svn, version 1.9') }
end

describe command('terraform --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include('Terraform v0.11') }
end
