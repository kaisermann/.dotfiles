# Install Homebrew
command -v brew > /dev/null || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew tap homebrew/php
brew update
brew upgrade

# Install packages

apps=(
  awscli
  composer
  coreutils
  csshx
  dockutil
  exiftool
  ffmpeg --with-fdk-aac --with-ffplay --with-freetype --with-libass --with-libquvi --with-libvorbis --with-libvpx --with-opus --with-x265
  fish
  gettext
  git
  grep --with-default-names
  imagemagick
  jq
  keychain
  ncdu
  nvm
  php-code-sniffer
  python
  shellcheck
  ssh-copy-id
  tree
  vim
  wget
  wifi-password
  wp-cli
  z
)

brew install "${apps[@]}"
