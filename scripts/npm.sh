printf "\n${YELLOW}>> Should install node?${NC}\n"
confirm && nvm install stable

# Globally install with npm
NPM_PACKAGES_I_CMD="npm install -g"

printf "\n${GREEN}>> Installing node packages${NC}\n"

packages=(
  degit
  diff-so-fancy
  express
  git-standup
  gulp-cli
  http-server
  npm-check-updates
  sass
  speed-test
  stylus
  yarn
  webpack
)

PCKGS="${packages[@]}"

rf "$NPM_PACKAGES_I_CMD $PCKGS"
