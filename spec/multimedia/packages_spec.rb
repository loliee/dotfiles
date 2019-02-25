require 'spec_helper'

%w(
  gifsicle
  graphviz
  jhead
  jpeg
  jpegoptim
  optipng
  pngcrush
  pngquant
  webkit2png
).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

# macOS specific
if os[:family] == 'darwin'

  %w(
    imageoptim
    gimp
    transmission
    vlc
  ).each do |p|
    describe command("brew cask info #{p}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should_not match /Not installed/ }
    end
  end
end
