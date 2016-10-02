#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Keyboard Layout
localectl set-x11-keymap layout macbook79 mac

# Services
systemctl enable docker || true
sudo usermod -aG docker "${CUSER}"

# Reconfigure locale
dpkg-reconfigure locales || true

# Set default chain policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Accept on localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

iptables -A INPUT -i docker0 -j ACCEPT
iptables -A OUTPUT -o docker0 -j ACCEPT

# Allow established sessions to receive traffic
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
iptables -I INPUT -p tcp --dport 22 -j ACCEPT
iptables-save > /etc/iptables/rules.v4

# Save
iptables-save
