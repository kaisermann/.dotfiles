#!/bin/bash
# Install packages
apps=(
  appcleaner
  diskwave
  firefox
  google-chrome
  google-drive
  handbrake
  istat-menus
  nordvpn
  qbittorrent
  spotify
  reactangle
  teamviewer
  telegram-desktop
  the-unarchiver
  tuple
  twist
  vlc
  whatsapp
)

for app in ${apps[*]}; do
  brew install $app
done

# Support for NTFS HD and sshfs mounts
# brew install ntfs-3g sshfs

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook quicklookase qlvideo
