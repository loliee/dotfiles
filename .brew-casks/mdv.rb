cask "mdv" do
  version "1.2.0,144"
  sha256 "722a5306ade2e58333166c70ac1380881deac6f9ae617a1fe2c448f6d06d873e"

  url "https://mowglii.s3.us-east-1.amazonaws.com/mdv/MDV-#{version.csv.second}-#{version.csv.first}.dmg",
      verified: "mowglii.s3.us-east-1.amazonaws.com/mdv/"
  name "MDV"
  desc "Markdown viewer with Mermaid, KaTeX and Quick Look support"
  homepage "https://www.mowglii.com/mdv/"

  livecheck do
    url "https://mowglii.s3.us-east-1.amazonaws.com/mdv/appcast.xml"
    strategy :sparkle
  end

  auto_updates true
  depends_on macos: ">= :ventura"

  app "MDV.app"
  binary "#{appdir}/MDV.app/Contents/bin/mdv"

  zap trash: [
    "~/Library/Caches/com.mowglii.MDV",
    "~/Library/Containers/com.mowglii.MDV.MDV-QuickLook",
    "~/Library/HTTPStorages/com.mowglii.MDV",
    "~/Library/Preferences/com.mowglii.MDV.plist",
    "~/Library/Saved Application State/com.mowglii.MDV.savedState",
    "~/Library/WebKit/com.mowglii.MDV",
  ]
end
