#!/bin/bash

# Change the default shell for the fish shell
if [[ ${SHELL} != *"fish"* ]]; then
  FISH_LOCATION=$(which fish)
  sudo -- sh -c "grep -q -F \"$FISH_LOCATION\" /etc/shells || echo \"$FISH_LOCATION\" >> /etc/shells"
  sudo chsh -s $FISH_LOCATION $(whoami)
fi

# Install oh my fish if not present
fish -c '
  if not type -q omf
    curl -L http://get.oh-my.fish | fish
    fish < /tmp/oh-my-fish.installer.fish
    rm -rf /tmp/oh-my-fish.installer.fish
  end
'

# Files to link to the .config directory
paths=(
  fish/init.fish
  omf/pkg/til
  omf/bundle
)

for path in ${paths[*]}; do
  mkdir -p ~/.config/$(dirname $path)
  ln -svf $(readlink -f ../content/fish)/$path ~/.config/$(dirname $path)/
done

# Install omf dependencies listed on 'bundle'
fish -c 'omf.bundle.install'
