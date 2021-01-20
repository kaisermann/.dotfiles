#!/bin/bash
# Install packages
apps=(
  appcleaner
  diskwave
  firefox
  flux
  google-backup-and-sync
  google-chrome
  handbrake
  imageoptim
  istat-menus
  licecap
  qbittorrent
  spectacle
  teamviewer
  telegram-desktop
  the-unarchiver
  vlc
)

for app in ${apps[*]}; do
  brew install $app
done

# Support for NTFS HD and sshfs mounts
# brew install ntfs-3g sshfs

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook quicklookase qlvideo
