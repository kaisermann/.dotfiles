printf "\n${YELLOW}>> Should install node?${NC}\n"
confirm && brew install node

# Globally install with npm
NPM_PACKAGES_I_CMD="npm install -g"
#printf "\n${YELLOW}>> Should install node packages with yarn?${NC}\n"
#confirm && NPM_PACKAGES_I_CMD="yarn global add"

printf "\n${GREEN}>> Installing node packages${NC}\n"
rf "command -v yarn > /dev/null; or npm install -g yarn;"

packages=(
  bower
  bower-update
  npm-check-updates
  diff-so-fancy
  express
  git-standup
  grunt
  gulp
  gulp-cli
  http-server
  less
  mustache
  sass
  stylus
  webpack
)
PCKGS="${packages[@]}"
rf "$NPM_PACKAGES_I_CMD $PCKGS"
