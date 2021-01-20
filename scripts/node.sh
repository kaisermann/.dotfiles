#!/bin/bash

# Install Homebrew
command -v volta > /dev/null || (curl https://get.volta.sh | bash)

# install Node
volta install node

#!/bin/bash
packages=(
  diff-so-fancy
  npm-check-updates
  sirv-cli
)

for package in ${packages[*]}; do
 volta install $package
done
