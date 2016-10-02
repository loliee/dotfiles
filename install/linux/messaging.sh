#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Hipchat
[[ -f /etc/apt/sources.list.d/atlassian-hipchat4.list ]] \
  || echo "deb https://atlassian.artifactoryonline.com/atlassian/hipchat-apt-client $(lsb_release -c -s) main" \
          > /etc/apt/sources.list.d/atlassian-hipchat4.list
wget -O - https://atlassian.artifactoryonline.com/atlassian/api/gpg/key/public | sudo apt-key add -
apt-get update
apt-get install -y hipchat4

# Slack
[[ -f /tmp/slack-desktop-2.2.1-amd64.deb ]] \
  || curl -L -o /tmp/slack-desktop-2.2.1-amd64.deb \
     https://downloads.slack-edge.com/linux_releases/slack-desktop-2.2.1-amd64.deb
dpkg --install /tmp/slack-desktop-2.2.1-amd64.deb
