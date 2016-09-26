if [ -f "${HOME}/.Xmodmap" ]; then
  /usr/bin/xmodmap "${HOME}/.Xmodmap"
fi

# Enable multimedia keys (daemonizes by default)
xbindkeys

# Set FR keyboard layout
setxkbmap -layout fr

# Start albert app launcher
albert &

exec startxfce4
