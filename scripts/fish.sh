# Let's change the default shellcheck
if [[ ${SHELL} != *"fish"* ]]; then
  printf "\n${YELLOW}>> Will configure fish as default shell${NC}\n"
  grep -q -F '/usr/local/bin/fish' /etc/shells || sudo echo '/usr/local/bin/fish' >> /etc/shells
  sudo chsh -s /usr/local/bin/fish $(whoami)
fi

# Installs oh my fish
#[ -d ~/.local/share/omf ] && $RM_CMD ~/.local/share/omf
printf "\n${YELLOW}>> Will install oh-my-fish${NC}\n"
curl -L http://get.oh-my.fish -o $DOTFILES_DIR/oh-my-fish.installer.fish
fish < $DOTFILES_DIR/oh-my-fish.installer.fish
${RM_CMD} $DOTFILES_DIR/oh-my-fish.installer.fish
