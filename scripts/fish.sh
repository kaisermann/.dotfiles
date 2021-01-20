#!/bin/bash
if [[ ${SHELL} != *"fish"* ]]; then
  FISH_LOCATION=$(which fish)
  echo $FISH_LOCATION
  sudo -- sh -c "grep -q -F \"$FISH_LOCATION\" /etc/shells || echo \"$FISH_LOCATION\" >> /etc/shells"
  sudo chsh -s $FISH_LOCATION $(whoami)
fi

# Install fisher
curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
fish -c fisher
