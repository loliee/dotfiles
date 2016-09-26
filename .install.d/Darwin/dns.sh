#!/usr/bin/env bash

set -o errexit
set -o pipefail

OS="$(uname)"
[[ $OS -ne 'Darwin' ]] && exit 0

echo '--> configure dnsmasq'

mkdir -p "$HOME/.dnsmasq.d"
cat <<EOT > /usr/local/etc/dnsmasq.conf
# https://github.com/drduh/OS-X-Security-and-Privacy-Guide#dnsmasq

# Forward queries to dnscrypt on localhost
server=127.0.0.1#5355

# Never forward plain names
domain-needed

# Blackhole Tor hidden services and local TLDs
address=/.onion/0.0.0.0
address=/.local/0.0.0.0
address=/.mycoolnetwork/0.0.0.0

# Never forward addresses in the non-routed address spaces
bogus-priv

# Reject private addresses from upstream nameservers
stop-dns-rebind

# Query servers in order
strict-order

# Set the size of the cache
# The default is to keep 150 hostnames
cache-size=8192

# Optional logging directives
log-async
log-dhcp
log-queries
log-facility=/var/log/dnsmasq.log

# Include localconfig
conf-dir=$HOME/.dnsmasq.d/
EOT

# Install and start the program
sudo cp -fv /usr/local/opt/dnsmasq/*.plist /Library/LaunchDaemons
sudo chown root /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist &> /dev/null
sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist

# Configure dnscrypt
sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.dnscrypt-proxy.plist &> /dev/null
sudo cp -fv /usr/local/opt/dnscrypt-proxy/*.plist /Library/LaunchDaemons
sudo chown root /Library/LaunchDaemons/homebrew.mxcl.dnscrypt-proxy.plist
sudo sed -i "/sbin\\/dnscrypt-proxy<\\/string>/a<string>--local-address=127.0.0.1:5355<\\/string>\n" \
	/Library/LaunchDaemons/homebrew.mxcl.dnscrypt-proxy.plist
sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.dnscrypt-proxy.plist

# Update resolvers
dnscrypt-update-resolvers

# Configure dns to use localhost
networksetup -listallnetworkservices | while read -r interface; do
  if [[ "$interface" == "*Ethernet" ]] \
    || [[ "$interface" == "Thunderbolt Ethernet" ]] \
    || [[ "$interface" == "Wi-Fi" ]]; then
    sudo networksetup -setdnsservers "$interface" 127.0.0.1
  fi
done
