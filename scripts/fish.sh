#!/bin/bash
if [[ ${SHELL} != *"fish"* ]]; then
  FISH_LOCATION=$(which fish)
  echo $FISH_LOCATION
  sudo -- sh -c "grep -q -F \"$FISH_LOCATION\" /etc/shells || echo \"$FISH_LOCATION\" >> /etc/shells"
  sudo chsh -s $FISH_LOCATION $(whoami)
fi

# Install oh my fish
# curl -L http://get.oh-my.fish -o /tmp/oh-my-fish.installer.fish
# fish < /tmp/oh-my-fish.installer.fish
# rm -rf /tmp/oh-my-fish.installer.fish

# Install fnm
# curl https://raw.githubusercontent.com/Schniz/fnm/master/.ci/install.sh | bash -s -- --skip-shell --force-install
brew install Schniz/tap/fnm

# Install fisher
curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
fish -c fisher
