require 'spec_helper'

casks_list= %x( brew cask list )

%w(
 imageoptim
 gimp
 transmission
 vlc
).each do |p|
  describe command("echo '#{casks_list}' | grep #{p}") do
    its(:exit_status) { should eq 0 }
  end
end

%w(
 gifsicle
 graphviz
 imagemagick
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
