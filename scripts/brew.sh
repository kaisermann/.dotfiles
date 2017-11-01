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
