cask "db-pro" do
  version "2.6.8"
  sha256 "db52e723d3e29b3eafa3498c7fd1176b482652ab1ecde1719041fa7192a58052"

  url "https://releases.dbpro.app/macos-arm64/DB%20Pro-#{version}-arm64.dmg"
  name "DB Pro"
  desc "Query, explore, and manage databases with a desktop app and built-in AI"
  homepage "https://www.dbpro.app/"

  # The app updates itself via electron-updater; bump this cask only when a
  # fresh install should start from a newer baseline.
  livecheck do
    url "https://releases.dbpro.app/macos-arm64/latest-mac.yml"
    strategy :electron_builder
  end

  auto_updates true

  app "DB Pro.app"

  zap trash: [
    "~/Library/Application Support/DB Pro",
    "~/Library/Preferences/com.dbpro.app.plist",
  ]
end
