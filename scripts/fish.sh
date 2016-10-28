# Let's change the default shellcheck

if [[ ${SHELL} != *"fish"* ]]; then
  printf "\n${YELLOW}>> Will configure fish as default shell${NC}\n"
  grep -q -F '/usr/local/bin/fish' /etc/shells || sudo echo '/usr/local/bin/fish' >> /etc/shells
  chsh -s /usr/local/bin/fish
fi

# Installs fisherman
printf "\n${YELLOW}>> Will install fisherman and necessary fish's packages${NC}\n"
[ -d ~/.config/fisherman ] && $RM_CMD ~/.config/fisherman
curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher

# Fish's packages
pkgs=(
  fisherman/autojump
  fisherman/pwd_info
  fisherman/pwd_is_home
  fisherman/host_info
  fisherman/last_job_id
  fisherman/humanize_duration
  oh-my-fish/plugin-argu
  oh-my-fish/plugin-brew
  oh-my-fish/plugin-ssh
  oh-my-fish/plugin-osx
  oh-my-fish/plugin-thefuck
  nyarly/fish-bang-bang
  derekstavis/plugin-nvm
  edc/bass
)

FISHER_CMD="fisher ${pkgs[@]}"
rf "${FISHER_CMD}"
