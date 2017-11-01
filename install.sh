#!/usr/bin/env bash
export DOTFILES_DIR YELLOW GREEN BLUE RED NC

YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ZIP_CMD="zip -r"

confirm () {
    read -r -p "${1:-Answer [y/N]}: " response
    case $response in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

rf () {
  fish -c "$1"
}

# Package managers & packages
printf "\n${YELLOW}>> Should install brew and brew packages${NC}\n"
confirm && . "$DOTFILES_DIR/scripts/brew.sh"

# Links the config folder to ~/.config
printf "\n${YELLOW}>> Should link config folder to ~/.config${NC}\n"
confirm && . "$DOTFILES_DIR/scripts/config.sh"

printf "\n${YELLOW}>> Should configure fish${NC}\n"
confirm && . "$DOTFILES_DIR/scripts/fish.sh"

# Install node and npm packages (nvm and npm)
printf "\n${YELLOW}>> Should install Node, NPM and global packages?${NC}\n"
confirm && . "$DOTFILES_DIR/scripts/npm.sh"

printf "\n${YELLOW}>> Should link home files (bash_profile, vimrc, etc)${NC}\n"
confirm && . "$DOTFILES_DIR/scripts/home.sh"

printf "\n${YELLOW}>> Should run dev post-installation setup (pip, wp-cli, etc)${NC}\n"
confirm && . "$DOTFILES_DIR/scripts/post.sh"

printf "${GREEN}--- DOTFILES - THE END ---${NC}\n\n"
