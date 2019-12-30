require 'spec_helper'

describe file("#{ENV['HOME']}/.gnupg/gpg.conf") do
  it { should be_file }
  it { should contain /personal-cipher-preferences AES256 AES192 AES/ }
  it { should contain /personal-digest-preferences SHA512 SHA384 SHA256/ }
  it { should contain /use-agent/ }
  it { should contain /require-cross-certification/ }
end
