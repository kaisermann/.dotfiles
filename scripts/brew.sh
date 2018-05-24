#!/bin/bash
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
  ffmpeg --with-fdk-aac --with-sdl2 --with-freetype --with-libass --with-libvorbis --with-libvpx --with-opus --with-x265
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

for app in ${apps[*]}; do
  brew cask install $app
done
