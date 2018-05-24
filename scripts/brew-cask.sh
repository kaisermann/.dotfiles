#!/bin/bash
# Install Caskroom

brew tap caskroom/cask
brew tap caskroom/versions

# Install packages
apps=(
  alfred
  appcleaner
  atom
  diskwave
  dropbox
  firefox
  flux
  google-chrome
  handbrake
  imageoptim
  istat-menus
  itau
  licecap
  mamp
  osxfuse
  sequel-pro
  sublime-text
  teamviewer
  telegram-desktop
  the-unarchiver
  transmit
  utorrent
  veracrypt
  visual-studio-code
  vlc
)

for app in ${apps[*]}; do
  brew cask install $app
done

# Support for NTFS HD and sshfs mounts
brew install ntfs-3g sshfs

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook quicklookase qlvideo
