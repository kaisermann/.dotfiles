# Install Homebrew

command -v brew > /dev/null || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew tap homebrew/versions
brew tap homebrew/dupes
brew tap homebrew/php
brew tap Goles/battery
brew update
brew upgrade

# Install packages

apps=(
  autojump
  awscli
  composer
  dockutil
  fish
  thefuck
  git
  grep --with-default-names
  imagemagick
  ncdu
  python
  shellcheck
  nvm
  ssh-copy-id
  rmtrash
  tree
  vim
  wget
  wifi-password
  wp-cli
  php-code-sniffer
)

brew install "${apps[@]}"
