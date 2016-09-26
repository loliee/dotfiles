#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

ENABLE_TOR=${ENABLE_TOR:=0}
DISK_CACHE=${DISK_CACHE:="$HOME/.polipo-cache"}

echo '--> setup polipo'

mkdir -p "$DISK_CACHE"

cat <<EOT > "$HOME/.polipo"
allowedClients = 127.0.0.1
allowedPorts = 1-65535
cacheIsShared = false
censorReferer = maybe
censoredHeaders = from,accept-language,x-pad,link
chunkHighMark = 67108864
disableVia = true
diskCacheRoot = "$DISK_CACHE"
disableIndexing = false
dnsUseGethostbyname = true # not recommended without dnscrypt-proxy
logSyslog = true
maxConnectionAge = 5m
maxConnectionRequests = 120
proxyAddress = "127.0.0.1"
proxyName = "localhost"
proxyPort = 8123
scrubLogs = false
tunnelAllowedPorts = 1-65535
EOT

if [[ $ENABLE_TOR -eq 1 ]]; then
  echo '--> setup tor'

  cat <<EOT >> "$HOME/.polipo"
diskCacheRoot=""
socksParentProxy = "localhost:9050"
socksProxyType = socks5
EOT

  cat <<EOT > /usr/local/etc/tor/torrc
ControlPort 9051
HardwareAccel 1
#HashedControlPassword $(tor --hash-password "$(pwgen 16)" | tail -n 1)
Log notice syslog
SocksPort 9050
EOT

  ln -sfv /usr/local/opt/tor/*.plist ~/Library/LaunchAgents
  launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.tor.plist
  launchctl load ~/Library/LaunchAgents/homebrew.mxcl.tor.plist
fi

mkdir -p ~/Library/LaunchAgents
ln -sfv /usr/local/opt/polipo/*.plist ~/Library/LaunchAgents
launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.polipo.plist
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.polipo.plist

networksetup -listallnetworkservices | while read -r interface; do
  if [[ "$interface" == "*Ethernet" ]] \
    || [[ "$interface" == "Thunderbolt Ethernet" ]] \
    || [[ "$interface" == "Wi-Fi" ]]; then
    sudo networksetup -setwebproxy "$interface" localhost 8123
    sudo networksetup -setsecurewebproxy "$interface" localhost 8123
    sudo networksetup -setproxybypassdomains "$interface" '*.local 169.254/16 localhost 127.0.0.1'
  fi
done
