# Install Caskroom

brew tap caskroom/cask
brew tap caskroom/versions

# Install packages

apps=(
  alfred
  atom
  diskwave
  dropbox
  firefox
  appcleaner
  flux
  google-chrome
  google-drive
  google-photos-backup
  handbrake
  imageoptim
  istat-menus
  itau
  licecap
  mamp
  opera
  osxfuse
  sequel-pro
  skype
  slack
  sourcetree
  teamviewer
  telegram-desktop
  the-unarchiver
  utorrent
  veracrypt
#  vagrant
#  virtualbox
  vlc
  vlc-remote
  xamarin-studio
  mono-mdk
  transmit
)

brew cask install "${apps[@]}"
brew install homebrew/fuse/ntfs-3g

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook

#vagrant plugin install vagrant-hostmanager
#vagrant plugin install vagrant-bindfs
