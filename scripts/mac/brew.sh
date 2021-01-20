#!/bin/bash
# Install Homebrew
command -v brew > /dev/null || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew update
brew upgrade

# Install packages

apps=(
  coreutils
  exiftool
  ffmpeg
  fish
  git
  grep
  imagemagick
  jq
  keychain
  ncdu
  ssh-copy-id
  tree
  vim
  z
)

for app in ${apps[*]}; do
  brew install $app
done
